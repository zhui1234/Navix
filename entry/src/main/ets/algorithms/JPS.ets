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

function sign(v: number): number {
  if (v > 0) {
    return 1
  }
  if (v < 0) {
    return -1
  }
  return 0
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

function moveCost(steps: number, dr: number, dc: number): number {
  if (dr !== 0 && dc !== 0) {
    return steps * Math.SQRT2
  }
  return steps
}

function distanceSteps(aRow: number, aCol: number, bRow: number, bCol: number): number {
  const dr = Math.abs(bRow - aRow)
  const dc = Math.abs(bCol - aCol)
  return Math.max(dr, dc)
}

function hasForcedNeighbor(map: GridMap, row: number, col: number, dr: number, dc: number, allowDiagonal: boolean): boolean {
  if (dr !== 0 && dc !== 0) {
    if (!map.isWalkable(row - dr, col) && map.isWalkable(row - dr, col + dc)) {
      return true
    }
    if (!map.isWalkable(row, col - dc) && map.isWalkable(row + dr, col - dc)) {
      return true
    }
    return false
  }
  if (dr !== 0) {
    if (!allowDiagonal) {
      return false
    }
    if (!map.isWalkable(row, col + 1) && map.isWalkable(row + dr, col + 1)) {
      return true
    }
    if (!map.isWalkable(row, col - 1) && map.isWalkable(row + dr, col - 1)) {
      return true
    }
    return false
  }
  if (dc !== 0) {
    if (!allowDiagonal) {
      return false
    }
    if (!map.isWalkable(row + 1, col) && map.isWalkable(row + 1, col + dc)) {
      return true
    }
    if (!map.isWalkable(row - 1, col) && map.isWalkable(row - 1, col + dc)) {
      return true
    }
  }
  return false
}

function jump(map: GridMap, row: number, col: number, dr: number, dc: number, endRow: number, endCol: number, allowDiagonal: boolean): GridPos | null {
  const nr = row + dr
  const nc = col + dc
  if (!map.isWalkable(nr, nc)) {
    return null
  }
  if (nr === endRow && nc === endCol) {
    return { row: nr, col: nc }
  }
  if (hasForcedNeighbor(map, nr, nc, dr, dc, allowDiagonal)) {
    return { row: nr, col: nc }
  }
  if (allowDiagonal && dr !== 0 && dc !== 0) {
    if (jump(map, nr, nc, dr, 0, endRow, endCol, allowDiagonal) !== null) {
      return { row: nr, col: nc }
    }
    if (jump(map, nr, nc, 0, dc, endRow, endCol, allowDiagonal) !== null) {
      return { row: nr, col: nc }
    }
  }
  return jump(map, nr, nc, dr, dc, endRow, endCol, allowDiagonal)
}

function getPrunedDirections(map: GridMap, row: number, col: number, parentId: number, cols: number, allowDiagonal: boolean): GridPos[] {
  const dirs: GridPos[] = []
  if (parentId === -1) {
    dirs.push({ row: -1, col: 0 })
    dirs.push({ row: 1, col: 0 })
    dirs.push({ row: 0, col: -1 })
    dirs.push({ row: 0, col: 1 })
    if (allowDiagonal) {
      dirs.push({ row: -1, col: -1 })
      dirs.push({ row: -1, col: 1 })
      dirs.push({ row: 1, col: -1 })
      dirs.push({ row: 1, col: 1 })
    }
    return dirs
  }

  const parent = posFromIndex(parentId, cols)
  const dr = sign(row - parent.row)
  const dc = sign(col - parent.col)

  if (!allowDiagonal) {
    if (dr !== 0) {
      dirs.push({ row: dr, col: 0 })
    } else if (dc !== 0) {
      dirs.push({ row: 0, col: dc })
    }
    return dirs
  }

  if (dr !== 0 && dc !== 0) {
    if (map.isWalkable(row, col + dc)) {
      dirs.push({ row: 0, col: dc })
    }
    if (map.isWalkable(row + dr, col)) {
      dirs.push({ row: dr, col: 0 })
    }
    if (map.isWalkable(row + dr, col + dc)) {
      dirs.push({ row: dr, col: dc })
    }
    if (!map.isWalkable(row - dr, col) && map.isWalkable(row - dr, col + dc)) {
      dirs.push({ row: -dr, col: dc })
    }
    if (!map.isWalkable(row, col - dc) && map.isWalkable(row + dr, col - dc)) {
      dirs.push({ row: dr, col: -dc })
    }
    return dirs
  }

  if (dr !== 0) {
    if (map.isWalkable(row + dr, col)) {
      dirs.push({ row: dr, col: 0 })
    }
    if (!map.isWalkable(row, col + 1) && map.isWalkable(row + dr, col + 1)) {
      dirs.push({ row: dr, col: 1 })
    }
    if (!map.isWalkable(row, col - 1) && map.isWalkable(row + dr, col - 1)) {
      dirs.push({ row: dr, col: -1 })
    }
    return dirs
  }

  if (dc !== 0) {
    if (map.isWalkable(row, col + dc)) {
      dirs.push({ row: 0, col: dc })
    }
    if (!map.isWalkable(row + 1, col) && map.isWalkable(row + 1, col + dc)) {
      dirs.push({ row: 1, col: dc })
    }
    if (!map.isWalkable(row - 1, col) && map.isWalkable(row - 1, col + dc)) {
      dirs.push({ row: -1, col: dc })
    }
  }
  return dirs
}

function expandPath(points: GridPos[]): GridPos[] {
  if (points.length <= 1) {
    return points
  }
  const path: GridPos[] = []
  path.push({ row: points[0].row, col: points[0].col })
  for (let i = 1; i < points.length; i++) {
    const a = points[i - 1]
    const b = points[i]
    const dr = sign(b.row - a.row)
    const dc = sign(b.col - a.col)
    let r = a.row
    let c = a.col
    while (!(r === b.row && c === b.col)) {
      r += dr
      c += dc
      path.push({ row: r, col: c })
    }
  }
  return path
}

export class JPSPathfinder {
  findPath(map: GridMap, start: GridPos, end: GridPos, options: PathfindingOptions): PathfindingResult {
    const rows = map.rows
    const cols = map.cols
    const n = rows * cols
    const startId = indexOfPos(start.row, start.col, cols)
    const endId = indexOfPos(end.row, end.col, cols)

    const g: number[] = new Array<number>(n)
    const prev: number[] = new Array<number>(n)
    const closed: boolean[] = new Array<boolean>(n)
    for (let i = 0; i < n; i++) {
      g[i] = Number.POSITIVE_INFINITY
      prev[i] = -1
      closed[i] = false
    }

    g[startId] = 0
    const open = new MinHeap()
    const h0 = heuristic(start.row, start.col, end.row, end.col, options.heuristicType) * options.heuristicWeight
    open.push(new HeapNode(startId, h0))

    const explored: GridPos[] = []

    while (open.size() > 0) {
      const node = open.pop()
      if (!node) {
        break
      }
      const id = node.id
      if (closed[id]) {
        continue
      }
      closed[id] = true

      const p = posFromIndex(id, cols)
      explored.push(p)
      if (options.onStep) {
        options.onStep(id, open.ids())
      }
      if (id === endId) {
        break
      }

      const dirs = getPrunedDirections(map, p.row, p.col, prev[id], cols, options.allowDiagonal)
      for (let i = 0; i < dirs.length; i++) {
        const d = dirs[i]
        const jp = jump(map, p.row, p.col, d.row, d.col, end.row, end.col, options.allowDiagonal)
        if (!jp) {
          continue
        }
        const jid = indexOfPos(jp.row, jp.col, cols)
        if (closed[jid]) {
          continue
        }
        const steps = distanceSteps(p.row, p.col, jp.row, jp.col)
        const tentative = g[id] + moveCost(steps, d.row, d.col)
        if (tentative < g[jid]) {
          g[jid] = tentative
          prev[jid] = id
          const h = heuristic(jp.row, jp.col, end.row, end.col, options.heuristicType) * options.heuristicWeight
          open.push(new HeapNode(jid, tentative + h))
        }
      }
    }

    const jumpPoints: GridPos[] = []
    if (!closed[endId]) {
      return { found: false, cost: 0, explored: explored, path: jumpPoints }
    }

    let cur = endId
    while (cur !== -1) {
      jumpPoints.push(posFromIndex(cur, cols))
      if (cur === startId) {
        break
      }
      cur = prev[cur]
    }
    jumpPoints.reverse()
    const path = expandPath(jumpPoints)

    return { found: true, cost: g[endId], explored: explored, path: path }
  }
}

