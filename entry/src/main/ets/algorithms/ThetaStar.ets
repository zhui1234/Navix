import { GridPos } from '../models/MapTypes'
import { MinHeap, HeapNode } from './MinHeap'
import { GridMap, PathfindingOptions, PathfindingResult } from './PathfindingTypes'

type HeuristicType = 'manhattan' | 'euclidean' | 'chebyshev' | 'octile'

function indexOfPos(row: number, col: number, cols: number): number {
  return row * cols + col
}

function posFromIndex(index: number, cols: number): GridPos {
  const row = Math.floor(index / cols)
  const col = index - row * cols
  return { row: row, col: col }
}

function heuristic(aRow: number, aCol: number, bRow: number, bCol: number, type: HeuristicType): number {
  const dx = Math.abs(aCol - bCol)
  const dy = Math.abs(aRow - bRow)
  if (type === 'manhattan') {
    return dx + dy
  }
  if (type === 'euclidean') {
    return Math.sqrt(dx * dx + dy * dy)
  }
  if (type === 'chebyshev') {
    return Math.max(dx, dy)
  }
  const f = Math.SQRT2 - 1
  return dx < dy ? f * dx + dy : f * dy + dx
}

function dist(a: GridPos, b: GridPos): number {
  const dx = a.col - b.col
  const dy = a.row - b.row
  return Math.sqrt(dx * dx + dy * dy)
}

function lineOfSight(map: GridMap, a: GridPos, b: GridPos): boolean {
  let x0 = a.col
  let y0 = a.row
  const x1 = b.col
  const y1 = b.row

  let dx = Math.abs(x1 - x0)
  let dy = Math.abs(y1 - y0)
  const sx = x0 < x1 ? 1 : -1
  const sy = y0 < y1 ? 1 : -1
  let err = dx - dy

  while (true) {
    if (!map.isWalkable(y0, x0)) {
      return false
    }
    if (x0 === x1 && y0 === y1) {
      break
    }
    const e2 = err * 2
    const stepX = e2 > -dy
    const stepY = e2 < dx
    if (stepX && stepY) {
      if (!map.isWalkable(y0, x0 + sx) || !map.isWalkable(y0 + sy, x0)) {
        return false
      }
    }
    if (stepX) {
      err -= dy
      x0 += sx
    }
    if (stepY) {
      err += dx
      y0 += sy
    }
  }
  return true
}

function rasterLine(a: GridPos, b: GridPos): GridPos[] {
  let x0 = a.col
  let y0 = a.row
  const x1 = b.col
  const y1 = b.row

  let dx = Math.abs(x1 - x0)
  let dy = Math.abs(y1 - y0)
  const sx = x0 < x1 ? 1 : -1
  const sy = y0 < y1 ? 1 : -1
  let err = dx - dy

  const res: GridPos[] = []
  while (true) {
    res.push({ row: y0, col: x0 })
    if (x0 === x1 && y0 === y1) {
      break
    }
    const e2 = err * 2
    if (e2 > -dy) {
      err -= dy
      x0 += sx
    }
    if (e2 < dx) {
      err += dx
      y0 += sy
    }
  }
  return res
}

export class ThetaStarPathfinder {
  findPath(map: GridMap, start: GridPos, end: GridPos, options: PathfindingOptions): PathfindingResult {
    const rows = map.rows
    const cols = map.cols
    const n = rows * cols
    const startId = indexOfPos(start.row, start.col, cols)
    const endId = indexOfPos(end.row, end.col, cols)

    const g: number[] = new Array<number>(n)
    const parent: number[] = new Array<number>(n)
    const closed: boolean[] = new Array<boolean>(n)
    for (let i = 0; i < n; i++) {
      g[i] = Number.POSITIVE_INFINITY
      parent[i] = -1
      closed[i] = false
    }

    g[startId] = 0
    parent[startId] = startId

    const open = new MinHeap()
    const h0 = heuristic(start.row, start.col, end.row, end.col, options.heuristicType) * options.heuristicWeight
    open.push(new HeapNode(startId, h0))

    const explored: GridPos[] = []

    while (open.size() > 0) {
      const node = open.pop()
      if (!node) {
        break
      }
      const s = node.id
      if (closed[s]) {
        continue
      }
      closed[s] = true

      const sp = posFromIndex(s, cols)
      explored.push(sp)
      if (options.onStep) {
        options.onStep(s, open.ids())
      }

      if (s === endId) {
        break
      }

      for (let dr = -1; dr <= 1; dr++) {
        for (let dc = -1; dc <= 1; dc++) {
          if (dr === 0 && dc === 0) {
            continue
          }
          if (!options.allowDiagonal && dr !== 0 && dc !== 0) {
            continue
          }
          const nr = sp.row + dr
          const nc = sp.col + dc
          if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) {
            continue
          }
          if (!map.isWalkable(nr, nc)) {
            continue
          }
          if (options.allowDiagonal && dr !== 0 && dc !== 0) {
            if (!map.isWalkable(sp.row + dr, sp.col) || !map.isWalkable(sp.row, sp.col + dc)) {
              continue
            }
          }
          const s2 = indexOfPos(nr, nc, cols)
          if (closed[s2]) {
            continue
          }

          const s2p: GridPos = { row: nr, col: nc }
          let tentative = Number.POSITIVE_INFINITY
          let newParent = -1

          const ps = parent[s]
          if (ps >= 0) {
            const psp = posFromIndex(ps, cols)
            if (lineOfSight(map, psp, s2p)) {
              tentative = g[ps] + dist(psp, s2p)
              newParent = ps
            }
          }

          if (newParent < 0) {
            tentative = g[s] + dist(sp, s2p)
            newParent = s
          }

          if (tentative < g[s2]) {
            g[s2] = tentative
            parent[s2] = newParent
            const h = heuristic(nr, nc, end.row, end.col, options.heuristicType) * options.heuristicWeight
            open.push(new HeapNode(s2, tentative + h))
          }
        }
      }
    }

    if (!closed[endId]) {
      return { found: false, cost: 0, explored: explored, path: [] }
    }

    const chain: number[] = []
    let cur = endId
    const safety = n + 5
    for (let i = 0; i < safety; i++) {
      chain.push(cur)
      if (cur === startId) {
        break
      }
      const p = parent[cur]
      if (p < 0 || p === cur) {
        cur = p < 0 ? -1 : p
      } else {
        cur = p
      }
      if (cur < 0) {
        break
      }
    }
    if (chain.length === 0 || chain[chain.length - 1] !== startId) {
      return { found: false, cost: 0, explored: explored, path: [] }
    }
    chain.reverse()

    const path: GridPos[] = []
    for (let i = 0; i < chain.length; i++) {
      const p = posFromIndex(chain[i], cols)
      if (i === 0) {
        path.push(p)
        continue
      }
      const prev = posFromIndex(chain[i - 1], cols)
      const seg = rasterLine(prev, p)
      for (let k = 1; k < seg.length; k++) {
        path.push(seg[k])
      }
    }

    return { found: true, cost: g[endId], explored: explored, path: path }
  }
}
