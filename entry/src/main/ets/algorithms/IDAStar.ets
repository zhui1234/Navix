import { GridPos } from '../models/MapTypes'
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

function stepCost(dr: number, dc: number): number {
  return (dr !== 0 && dc !== 0) ? Math.SQRT2 : 1
}

function pushNeighborDirs(allowDiagonal: boolean): GridPos[] {
  const dirs: GridPos[] = []
  for (let dr = -1; dr <= 1; dr++) {
    for (let dc = -1; dc <= 1; dc++) {
      if (dr === 0 && dc === 0) {
        continue
      }
      if (!allowDiagonal && dr !== 0 && dc !== 0) {
        continue
      }
      dirs.push({ row: dr, col: dc })
    }
  }
  return dirs
}

export class IDAStarPathfinder {
  findPath(map: GridMap, start: GridPos, end: GridPos, options: PathfindingOptions): PathfindingResult {
    const rows = map.rows
    const cols = map.cols
    const n = rows * cols
    const startId = indexOfPos(start.row, start.col, cols)
    const endId = indexOfPos(end.row, end.col, cols)

    const visited: boolean[] = new Array<boolean>(n)
    for (let i = 0; i < n; i++) {
      visited[i] = false
    }

    const bufferedSteps: number[] = []
    const pathStack: number[] = []
    const dirs = pushNeighborDirs(options.allowDiagonal)

    const h0 = heuristic(start.row, start.col, end.row, end.col, options.heuristicType) * options.heuristicWeight
    let threshold = h0

    const maxIterations = n * 4
    let iter = 0

    let iterationExploredIds: number[] = []

    const dfs = (id: number, g: number, bound: number): number => {
      const p = posFromIndex(id, cols)
      const h = heuristic(p.row, p.col, end.row, end.col, options.heuristicType) * options.heuristicWeight
      const f = g + h
      if (f > bound) {
        return f
      }
      iterationExploredIds.push(id)
      if (options.onStep) {
        bufferedSteps.push(id)
      }
      if (id === endId) {
        return -1
      }

      let min = Number.POSITIVE_INFINITY
      for (let i = 0; i < dirs.length; i++) {
        const d = dirs[i]
        const nr = p.row + d.row
        const nc = p.col + d.col
        if (!map.isWalkable(nr, nc)) {
          continue
        }
        const nid = indexOfPos(nr, nc, cols)
        if (visited[nid]) {
          continue
        }
        visited[nid] = true
        pathStack.push(nid)
        const t = dfs(nid, g + stepCost(d.row, d.col), bound)
        if (t === -1) {
          return -1
        }
        if (t < min) {
          min = t
        }
        pathStack.pop()
        visited[nid] = false
      }
      return min
    }

    while (iter < maxIterations) {
      iter++
      bufferedSteps.length = 0
      for (let i = 0; i < n; i++) {
        visited[i] = false
      }
      pathStack.length = 0
      pathStack.push(startId)
      visited[startId] = true
      iterationExploredIds = []

      const t = dfs(startId, 0, threshold)
      if (t === -1) {
        if (options.onStep) {
          for (let i = 0; i < bufferedSteps.length; i++) {
            options.onStep(bufferedSteps[i], [])
          }
        }
        const path: GridPos[] = []
        for (let i = 0; i < pathStack.length; i++) {
          path.push(posFromIndex(pathStack[i], cols))
        }
        let cost = 0
        for (let i = 1; i < path.length; i++) {
          const a = path[i - 1]
          const b = path[i]
          cost += stepCost(b.row - a.row, b.col - a.col)
        }
        const explored: GridPos[] = []
        for (let i = 0; i < iterationExploredIds.length; i++) {
          explored.push(posFromIndex(iterationExploredIds[i], cols))
        }
        return { found: true, cost: cost, explored: explored, path: path }
      }
      if (!Number.isFinite(t) || t === Number.POSITIVE_INFINITY) {
        break
      }
      threshold = t
    }

    if (options.onStep) {
      for (let i = 0; i < bufferedSteps.length; i++) {
        options.onStep(bufferedSteps[i], [])
      }
    }
    const explored: GridPos[] = []
    for (let i = 0; i < iterationExploredIds.length; i++) {
      explored.push(posFromIndex(iterationExploredIds[i], cols))
    }
    return { found: false, cost: 0, explored: explored, path: [] }
  }
}
