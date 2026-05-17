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

export class AStarPathfinder {
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

      const baseRow = p.row
      const baseCol = p.col

      for (let dr = -1; dr <= 1; dr++) {
        for (let dc = -1; dc <= 1; dc++) {
          if (dr === 0 && dc === 0) {
            continue
          }
          if (!options.allowDiagonal && dr !== 0 && dc !== 0) {
            continue
          }
          const nr = baseRow + dr
          const nc = baseCol + dc
          if (!map.isWalkable(nr, nc)) {
            continue
          }
          if (options.allowDiagonal && dr !== 0 && dc !== 0) {
            if (!map.isWalkable(baseRow + dr, baseCol) || !map.isWalkable(baseRow, baseCol + dc)) {
              continue
            }
          }
          if (!options.allowDiagonal && (nr !== baseRow && nc !== baseCol)) {
            continue
          }
          const nid = indexOfPos(nr, nc, cols)
          if (closed[nid]) {
            continue
          }

          const stepCost = (dr !== 0 && dc !== 0) ? Math.SQRT2 : 1
          const tentative = g[id] + stepCost
          if (tentative < g[nid]) {
            g[nid] = tentative
            prev[nid] = id
            const h = heuristic(nr, nc, end.row, end.col, options.heuristicType) * options.heuristicWeight
            open.push(new HeapNode(nid, tentative + h))
          }
        }
      }
    }

    const path: GridPos[] = []
    if (!closed[endId]) {
      return { found: false, cost: 0, explored: explored, path: path }
    }

    let cur = endId
    while (cur !== -1) {
      path.push(posFromIndex(cur, cols))
      if (cur === startId) {
        break
      }
      cur = prev[cur]
    }
    path.reverse()

    return { found: true, cost: g[endId], explored: explored, path: path }
  }
}
