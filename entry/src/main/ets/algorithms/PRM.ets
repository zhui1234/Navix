import { GridPos } from '../models/MapTypes'
import { MinHeap, HeapNode } from './MinHeap'
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

interface Edge {
  to: number
  w: number
}

interface NeighborDist {
  j: number
  d: number
}

export class PRMPathfinder {
  findPath(map: GridMap, start: GridPos, end: GridPos, options: PathfindingOptions): PathfindingResult {
    const rows = map.rows
    const cols = map.cols
    if (!map.isWalkable(start.row, start.col) || !map.isWalkable(end.row, end.col)) {
      return { found: false, cost: 0, explored: [], path: [] }
    }

    const sampleTarget = 250
    const k = 10
    const maxSamples = rows * cols
    const want = sampleTarget < maxSamples ? sampleTarget : maxSamples

    const nodes: GridPos[] = []
    nodes.push({ row: start.row, col: start.col })
    nodes.push({ row: end.row, col: end.col })

    const used: boolean[] = new Array<boolean>(rows * cols).fill(false)
    used[indexOfPos(start.row, start.col, cols)] = true
    used[indexOfPos(end.row, end.col, cols)] = true

    const explored: GridPos[] = []
    explored.push({ row: start.row, col: start.col })
    explored.push({ row: end.row, col: end.col })

    let attempts = 0
    while (nodes.length < want && attempts < want * 40) {
      attempts++
      const r = Math.floor(Math.random() * rows)
      const c = Math.floor(Math.random() * cols)
      if (!map.isWalkable(r, c)) {
        continue
      }
      const id = indexOfPos(r, c, cols)
      if (used[id]) {
        continue
      }
      used[id] = true
      nodes.push({ row: r, col: c })
      explored.push({ row: r, col: c })
    }

    const graph: Edge[][] = []
    for (let i = 0; i < nodes.length; i++) {
      graph[i] = []
    }

    for (let i = 0; i < nodes.length; i++) {
      const dists: NeighborDist[] = []
      for (let j = 0; j < nodes.length; j++) {
        if (i === j) {
          continue
        }
        dists.push({ j, d: dist(nodes[i], nodes[j]) })
      }
      dists.sort((a, b) => a.d - b.d)
      const limit = dists.length < k ? dists.length : k
      for (let t = 0; t < limit; t++) {
        const j = dists[t].j
        if (!lineOfSight(map, nodes[i], nodes[j])) {
          continue
        }
        const w = dists[t].d
        graph[i].push({ to: j, w })
      }
    }

    const n = nodes.length
    const g: number[] = new Array<number>(n)
    const prev: number[] = new Array<number>(n)
    const closed: boolean[] = new Array<boolean>(n)
    for (let i = 0; i < n; i++) {
      g[i] = Number.POSITIVE_INFINITY
      prev[i] = -1
      closed[i] = false
    }
    g[0] = 0

    const open = new MinHeap()
    open.push(new HeapNode(0, 0))

    while (open.size() > 0) {
      const node = open.pop()
      if (!node) {
        break
      }
      const u = node.id
      if (u < 0 || u >= n) {
        continue
      }
      if (closed[u]) {
        continue
      }
      closed[u] = true
      if (options.onStep) {
        options.onStep(indexOfPos(nodes[u].row, nodes[u].col, cols), [])
      }
      if (u === 1) {
        break
      }
      const edges = graph[u]
      for (let i = 0; i < edges.length; i++) {
        const e = edges[i]
        const v = e.to
        if (closed[v]) {
          continue
        }
        const tentative = g[u] + e.w
        if (tentative < g[v]) {
          g[v] = tentative
          prev[v] = u
          open.push(new HeapNode(v, tentative))
        }
      }
    }

    if (!closed[1]) {
      return { found: false, cost: 0, explored: explored, path: [] }
    }

    const chain: number[] = []
    let cur = 1
    for (let i = 0; i < n + 5; i++) {
      chain.push(cur)
      if (cur === 0) {
        break
      }
      cur = prev[cur]
      if (cur < 0) {
        break
      }
    }
    if (chain.length === 0 || chain[chain.length - 1] !== 0) {
      return { found: false, cost: 0, explored: explored, path: [] }
    }
    chain.reverse()

    const path: GridPos[] = []
    for (let i = 0; i < chain.length; i++) {
      const p = nodes[chain[i]]
      path.push({ row: p.row, col: p.col })
    }

    return { found: true, cost: g[1], explored: explored, path: path }
  }
}
