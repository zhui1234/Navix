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

class Key {
  k1: number
  k2: number

  constructor(k1: number, k2: number) {
    this.k1 = k1
    this.k2 = k2
  }
}

function lessKey(a: Key, b: Key): boolean {
  if (a.k1 < b.k1) {
    return true
  }
  if (a.k1 > b.k1) {
    return false
  }
  return a.k2 < b.k2
}

function equalKey(a: Key, b: Key): boolean {
  return Math.abs(a.k1 - b.k1) < 1e-9 && Math.abs(a.k2 - b.k2) < 1e-9
}

class QueueNode {
  id: number
  key: Key

  constructor(id: number, key: Key) {
    this.id = id
    this.key = key
  }
}

class KeyMinHeap {
  private data: QueueNode[] = []

  size(): number {
    return this.data.length
  }

  ids(): number[] {
    const res: number[] = []
    for (let i = 0; i < this.data.length; i++) {
      res.push(this.data[i].id)
    }
    return res
  }

  peek(): QueueNode | null {
    if (this.data.length === 0) {
      return null
    }
    return this.data[0]
  }

  push(node: QueueNode): void {
    this.data.push(node)
    this.bubbleUp(this.data.length - 1)
  }

  pop(): QueueNode | null {
    if (this.data.length === 0) {
      return null
    }
    const top = this.data[0]
    const last = this.data.pop()!
    if (this.data.length > 0) {
      this.data[0] = last
      this.bubbleDown(0)
    }
    return top
  }

  private bubbleUp(index: number): void {
    let i = index
    while (i > 0) {
      const p = (i - 1) >> 1
      if (!lessKey(this.data[i].key, this.data[p].key)) {
        break
      }
      const tmp = this.data[p]
      this.data[p] = this.data[i]
      this.data[i] = tmp
      i = p
    }
  }

  private bubbleDown(index: number): void {
    let i = index
    const n = this.data.length
    while (true) {
      const l = i * 2 + 1
      const r = l + 1
      if (l >= n) {
        break
      }
      let m = l
      if (r < n && lessKey(this.data[r].key, this.data[l].key)) {
        m = r
      }
      if (!lessKey(this.data[m].key, this.data[i].key)) {
        break
      }
      const tmp = this.data[i]
      this.data[i] = this.data[m]
      this.data[m] = tmp
      i = m
    }
  }
}

export interface DStarLiteReplanResult {
  result: PathfindingResult
  expandedIds: number[]
}

export class DStarLitePlanner {
  private map: GridMap
  private rows: number
  private cols: number
  private n: number
  private allowDiagonal: boolean
  private heuristicType: HeuristicType
  private heuristicWeight: number

  private startId: number
  private goalId: number
  private km: number = 0

  private g: number[]
  private rhs: number[]
  private open: KeyMinHeap = new KeyMinHeap()

  constructor(map: GridMap, start: GridPos, goal: GridPos, options: PathfindingOptions) {
    this.map = map
    this.rows = map.rows
    this.cols = map.cols
    this.n = this.rows * this.cols
    this.allowDiagonal = options.allowDiagonal
    this.heuristicType = options.heuristicType
    this.heuristicWeight = (options.heuristicWeight > 1 ? 1 : (options.heuristicWeight <= 0 ? 1 : options.heuristicWeight))

    this.startId = indexOfPos(start.row, start.col, this.cols)
    this.goalId = indexOfPos(goal.row, goal.col, this.cols)

    this.g = new Array<number>(this.n)
    this.rhs = new Array<number>(this.n)
    for (let i = 0; i < this.n; i++) {
      this.g[i] = Number.POSITIVE_INFINITY
      this.rhs[i] = Number.POSITIVE_INFINITY
    }

    this.rhs[this.goalId] = 0
    this.open.push(new QueueNode(this.goalId, this.calculateKey(this.goalId)))
  }

  moveStart(nextStart: GridPos): void {
    const nextId = indexOfPos(nextStart.row, nextStart.col, this.cols)
    const prev = posFromIndex(this.startId, this.cols)
    this.km += this.h(prev.row, prev.col, nextStart.row, nextStart.col)
    this.startId = nextId
  }

  notifyCellChanged(row: number, col: number): void {
    const id = indexOfPos(row, col, this.cols)
    const neigh = this.neighborsOfId(id)
    this.updateVertex(id)
    for (let i = 0; i < neigh.length; i++) {
      this.updateVertex(neigh[i])
    }
  }

  replan(options?: PathfindingOptions): DStarLiteReplanResult {
    const expandedIds: number[] = []
    this.computeShortestPath(expandedIds, options)
    const res = this.buildResult(expandedIds)
    return { result: res, expandedIds: expandedIds }
  }

  private buildResult(expandedIds: number[]): PathfindingResult {
    const explored: GridPos[] = []
    for (let i = 0; i < expandedIds.length; i++) {
      explored.push(posFromIndex(expandedIds[i], this.cols))
    }

    const path: GridPos[] = []
    const startPos = posFromIndex(this.startId, this.cols)
    const goalPos = posFromIndex(this.goalId, this.cols)
    if (!this.map.isWalkable(startPos.row, startPos.col) || !this.map.isWalkable(goalPos.row, goalPos.col)) {
      return { found: false, cost: 0, explored: explored, path: path }
    }
    if (!Number.isFinite(this.g[this.startId])) {
      return { found: false, cost: 0, explored: explored, path: path }
    }

    let cur = this.startId
    path.push(startPos)
    const safety = this.n + 5
    for (let step = 0; step < safety; step++) {
      if (cur === this.goalId) {
        break
      }
      const next = this.bestSuccessor(cur)
      if (next < 0) {
        break
      }
      cur = next
      path.push(posFromIndex(cur, this.cols))
    }

    const found = path.length > 0 && path[path.length - 1].row === goalPos.row && path[path.length - 1].col === goalPos.col
    return { found: found, cost: found ? this.g[this.startId] : 0, explored: explored, path: found ? path : [] }
  }

  private computeShortestPath(expandedIds: number[], options?: PathfindingOptions): void {
    const maxIter = this.n * 50
    for (let iter = 0; iter < maxIter; iter++) {
      const top = this.open.peek()
      if (!top) {
        break
      }
      const startKey = this.calculateKey(this.startId)
      if (!lessKey(top.key, startKey) && this.rhs[this.startId] === this.g[this.startId]) {
        break
      }

      const node = this.open.pop()
      if (!node) {
        break
      }
      const u = node.id
      const kOld = node.key
      const kNew = this.calculateKey(u)
      if (lessKey(kOld, kNew) && !equalKey(kOld, kNew)) {
        this.open.push(new QueueNode(u, kNew))
        continue
      }
      if (this.g[u] === this.rhs[u]) {
        continue
      }

      expandedIds.push(u)
      if (options && options.onStep) {
        options.onStep(u, this.open.ids())
      }

      if (this.g[u] > this.rhs[u]) {
        this.g[u] = this.rhs[u]
        const preds = this.neighborsOfId(u)
        for (let i = 0; i < preds.length; i++) {
          this.updateVertex(preds[i])
        }
      } else {
        this.g[u] = Number.POSITIVE_INFINITY
        this.updateVertex(u)
        const preds = this.neighborsOfId(u)
        for (let i = 0; i < preds.length; i++) {
          this.updateVertex(preds[i])
        }
      }
    }
  }

  private updateVertex(u: number): void {
    if (u !== this.goalId) {
      const succ = this.neighborsOfId(u)
      let best = Number.POSITIVE_INFINITY
      for (let i = 0; i < succ.length; i++) {
        const v = succ[i]
        const c = this.cost(u, v)
        if (!Number.isFinite(c)) {
          continue
        }
        const val = c + this.g[v]
        if (val < best) {
          best = val
        }
      }
      this.rhs[u] = best
    }
    if (this.g[u] !== this.rhs[u]) {
      this.open.push(new QueueNode(u, this.calculateKey(u)))
    }
  }

  private calculateKey(id: number): Key {
    const p = posFromIndex(id, this.cols)
    const s = posFromIndex(this.startId, this.cols)
    const m = Math.min(this.g[id], this.rhs[id])
    const h = this.h(s.row, s.col, p.row, p.col)
    return new Key(m + h + this.km, m)
  }

  private h(aRow: number, aCol: number, bRow: number, bCol: number): number {
    return heuristic(aRow, aCol, bRow, bCol, this.heuristicType) * this.heuristicWeight
  }

  private cost(u: number, v: number): number {
    const pu = posFromIndex(u, this.cols)
    const pv = posFromIndex(v, this.cols)
    if (!this.map.isWalkable(pu.row, pu.col) || !this.map.isWalkable(pv.row, pv.col)) {
      return Number.POSITIVE_INFINITY
    }
    const dr = Math.abs(pu.row - pv.row)
    const dc = Math.abs(pu.col - pv.col)
    if (dr + dc === 1) {
      return 1
    }
    if (dr === 1 && dc === 1) {
      if (!this.map.isWalkable(pu.row, pv.col) || !this.map.isWalkable(pv.row, pu.col)) {
        return Number.POSITIVE_INFINITY
      }
      return Math.SQRT2
    }
    return Number.POSITIVE_INFINITY
  }

  private neighborsOfId(id: number): number[] {
    const p = posFromIndex(id, this.cols)
    const res: number[] = []
    for (let dr = -1; dr <= 1; dr++) {
      for (let dc = -1; dc <= 1; dc++) {
        if (dr === 0 && dc === 0) {
          continue
        }
        if (!this.allowDiagonal && dr !== 0 && dc !== 0) {
          continue
        }
        const nr = p.row + dr
        const nc = p.col + dc
        if (nr < 0 || nr >= this.rows || nc < 0 || nc >= this.cols) {
          continue
        }
        if (!this.map.isWalkable(nr, nc) && !(nr === p.row && nc === p.col)) {
          const nid = indexOfPos(nr, nc, this.cols)
          res.push(nid)
          continue
        }
        const nid = indexOfPos(nr, nc, this.cols)
        res.push(nid)
      }
    }
    return res
  }

  private bestSuccessor(u: number): number {
    const succ = this.neighborsOfId(u)
    let best = Number.POSITIVE_INFINITY
    let bestId = -1
    for (let i = 0; i < succ.length; i++) {
      const v = succ[i]
      const c = this.cost(u, v)
      if (!Number.isFinite(c)) {
        continue
      }
      const val = c + this.g[v]
      if (val < best) {
        best = val
        bestId = v
      }
    }
    return bestId
  }
}

export class DStarLitePathfinder {
  findPath(map: GridMap, start: GridPos, end: GridPos, options: PathfindingOptions): PathfindingResult {
    const planner = new DStarLitePlanner(map, start, end, options)
    const out = planner.replan(options)
    return out.result
  }
}
