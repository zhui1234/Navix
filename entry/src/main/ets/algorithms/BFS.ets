import { GridPos } from '../models/MapTypes'
import { GridMap, PathfindingOptions, PathfindingResult } from './PathfindingTypes'

function indexOfPos(row: number, col: number, cols: number): number {
  return row * cols + col
}

function posFromIndex(index: number, cols: number): GridPos {
  const row = Math.floor(index / cols)
  const col = index - row * cols
  return { row: row, col: col }
}

function stepCost(fromId: number, toId: number, cols: number): number {
  const fr = Math.floor(fromId / cols)
  const fc = fromId - fr * cols
  const tr = Math.floor(toId / cols)
  const tc = toId - tr * cols
  return (fr !== tr && fc !== tc) ? Math.SQRT2 : 1
}

export class BFSPathfinder {
  findPath(map: GridMap, start: GridPos, end: GridPos, options: PathfindingOptions): PathfindingResult {
    const rows = map.rows
    const cols = map.cols
    const n = rows * cols
    const startId = indexOfPos(start.row, start.col, cols)
    const endId = indexOfPos(end.row, end.col, cols)

    const prev: number[] = new Array<number>(n)
    const visited: boolean[] = new Array<boolean>(n)
    for (let i = 0; i < n; i++) {
      prev[i] = -1
      visited[i] = false
    }

    const queue: number[] = []
    let head = 0
    queue.push(startId)
    visited[startId] = true

    const explored: GridPos[] = []

    while (head < queue.length) {
      const id = queue[head++]
      explored.push(posFromIndex(id, cols))
      if (options.onStep) {
        const openIds: number[] = []
        for (let i = head; i < queue.length; i++) {
          openIds.push(queue[i])
        }
        options.onStep(id, openIds)
      }

      if (id === endId) {
        break
      }

      const base = posFromIndex(id, cols)
      for (let dr = -1; dr <= 1; dr++) {
        for (let dc = -1; dc <= 1; dc++) {
          if (dr === 0 && dc === 0) {
            continue
          }
          if (!options.allowDiagonal && dr !== 0 && dc !== 0) {
            continue
          }
          const nr = base.row + dr
          const nc = base.col + dc
          if (!map.isWalkable(nr, nc)) {
            continue
          }
          const nid = indexOfPos(nr, nc, cols)
          if (visited[nid]) {
            continue
          }
          visited[nid] = true
          prev[nid] = id
          queue.push(nid)
        }
      }
    }

    const path: GridPos[] = []
    if (!visited[endId]) {
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

    let cost = 0
    for (let i = 1; i < path.length; i++) {
      const a = indexOfPos(path[i - 1].row, path[i - 1].col, cols)
      const b = indexOfPos(path[i].row, path[i].col, cols)
      cost += stepCost(a, b, cols)
    }

    return { found: true, cost: cost, explored: explored, path: path }
  }
}

