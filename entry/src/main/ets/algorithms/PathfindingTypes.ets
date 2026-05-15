import { GridPos, MapData, NodeType } from '../models/MapTypes'

export interface GridMap {
  rows: number
  cols: number
  isWalkable(row: number, col: number): boolean
}

export interface PathfindingOptions {
  allowDiagonal: boolean
  heuristicType: 'manhattan' | 'euclidean' | 'chebyshev' | 'octile'
  heuristicWeight: number
  onStep?: (currentId: number, openIds: number[]) => void
}

export interface PathfindingResult {
  found: boolean
  cost: number
  explored: GridPos[]
  path: GridPos[]
}

export class GridMapFromMapData implements GridMap {
  rows: number
  cols: number
  private grid: NodeType[][]

  constructor(mapData: MapData) {
    this.rows = mapData.rows
    this.cols = mapData.cols
    this.grid = mapData.grid
  }

  isWalkable(row: number, col: number): boolean {
    if (row < 0 || row >= this.rows || col < 0 || col >= this.cols) {
      return false
    }
    return this.grid[row][col] !== NodeType.OBSTACLE
  }
}
