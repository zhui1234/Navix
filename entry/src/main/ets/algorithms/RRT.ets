import { GridPos } from '../models/MapTypes'
import { GridMap, PathfindingOptions, PathfindingResult } from './PathfindingTypes'

function indexOfPos(row: number, col: number, cols: number): number {
  return row * cols + col
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

function stepToward(map: GridMap, from: GridPos, to: GridPos, maxStep: number): GridPos | null {
  if (from.row === to.row && from.col === to.col) {
    return null
  }
  const dx = to.col - from.col
  const dy = to.row - from.row
  const d = Math.sqrt(dx * dx + dy * dy)
  if (d < 1e-9) {
    return null
  }
  const scale = d > maxStep ? (maxStep / d) : 1
  const tx = from.col + dx * scale
  const ty = from.row + dy * scale
  const target: GridPos = { row: Math.round(ty), col: Math.round(tx) }
  if (!map.isWalkable(target.row, target.col)) {
    return null
  }
  if (!lineOfSight(map, from, target)) {
    const near: GridPos[] = []
    for (let dr = -1; dr <= 1; dr++) {
      for (let dc = -1; dc <= 1; dc++) {
        if (dr === 0 && dc === 0) {
          continue
        }
        const nr = target.row + dr
        const nc = target.col + dc
        if (map.isWalkable(nr, nc)) {
          near.push({ row: nr, col: nc })
        }
      }
    }
    let best: GridPos | null = null
    let bestD = Number.POSITIVE_INFINITY
    for (let i = 0; i < near.length; i++) {
      const p = near[i]
      if (!lineOfSight(map, from, p)) {
        continue
      }
      const dd = dist(p, to)
      if (dd < bestD) {
        bestD = dd
        best = p
      }
    }
    return best
  }
  return target
}

export class RRTPathfinder {
  findPath(map: GridMap, start: GridPos, end: GridPos, options: PathfindingOptions): PathfindingResult {
    const rows = map.rows
    const cols = map.cols
    const startId = indexOfPos(start.row, start.col, cols)
    if (!map.isWalkable(start.row, start.col) || !map.isWalkable(end.row, end.col)) {
      return { found: false, cost: 0, explored: [], path: [] }
    }

    const maxIterations = 8000
    const goalBias = 0.08
    const stepSize = options.allowDiagonal ? 6 : 4
    const connectThreshold = stepSize + 1

    const nodes: GridPos[] = []
    const parent: number[] = []
    nodes.push({ row: start.row, col: start.col })
    parent.push(-1)

    const explored: GridPos[] = []
    explored.push({ row: start.row, col: start.col })

    const occupied: boolean[] = new Array<boolean>(rows * cols).fill(false)
    occupied[startId] = true

    let goalIndex = -1

    for (let iter = 0; iter < maxIterations; iter++) {
      const sample: GridPos = (Math.random() < goalBias)
        ? { row: end.row, col: end.col }
        : { row: Math.floor(Math.random() * rows), col: Math.floor(Math.random() * cols) }

      if (!map.isWalkable(sample.row, sample.col)) {
        continue
      }

      let nearest = 0
      let bestD = Number.POSITIVE_INFINITY
      for (let i = 0; i < nodes.length; i++) {
        const d = dist(nodes[i], sample)
        if (d < bestD) {
          bestD = d
          nearest = i
        }
      }

      const from = nodes[nearest]
      const next = stepToward(map, from, sample, stepSize)
      if (!next) {
        continue
      }

      const nid = indexOfPos(next.row, next.col, cols)
      if (nid < 0 || nid >= occupied.length || occupied[nid]) {
        continue
      }

      nodes.push(next)
      parent.push(nearest)
      occupied[nid] = true
      explored.push(next)
      if (options.onStep) {
        options.onStep(nid, [])
      }

      if (dist(next, end) <= connectThreshold && lineOfSight(map, next, end)) {
        nodes.push({ row: end.row, col: end.col })
        parent.push(nodes.length - 2)
        goalIndex = nodes.length - 1
        explored.push({ row: end.row, col: end.col })
        break
      }
    }

    if (goalIndex < 0) {
      return { found: false, cost: 0, explored: explored, path: [] }
    }

    const chain: number[] = []
    let cur = goalIndex
    for (let i = 0; i < nodes.length + 5; i++) {
      chain.push(cur)
      if (cur === 0) {
        break
      }
      cur = parent[cur]
      if (cur < 0) {
        break
      }
    }
    if (chain.length === 0 || chain[chain.length - 1] !== 0) {
      return { found: false, cost: 0, explored: explored, path: [] }
    }
    chain.reverse()

    const path: GridPos[] = []
    let cost = 0
    for (let i = 0; i < chain.length; i++) {
      const p = nodes[chain[i]]
      if (i > 0) {
        cost += dist(nodes[chain[i - 1]], p)
      }
      path.push({ row: p.row, col: p.col })
    }

    return { found: true, cost: cost, explored: explored, path: path }
  }
}
