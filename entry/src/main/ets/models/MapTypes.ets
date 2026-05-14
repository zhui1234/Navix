export interface GridPos {
  row: number
  col: number
}

export enum NodeType {
  EMPTY = 0,
  START = 1,
  END = 2,
  OBSTACLE = 3,
  PATH = 4,
  EXPLORED = 5
}

export interface MapData {
  grid: NodeType[][]
  rows: number
  cols: number
}

export enum LeftPanelState {
  COLLAPSED = 0,
  TOOLS = 1,
  ALGORITHMS = 2
}

export enum RightPanelState {
  COLLAPSED = 0,
  MAP_SELECT = 1,
  PARAMS = 2,
  HEATMAP = 3
}

export enum ToolType {
  SELECT = 0,
  START = 1,
  END = 2,
  OBSTACLE = 3,
  ERASER = 4,
  RANDOM = 5
}

export enum AlgorithmType {
  ASTAR = 0,
  DIJKSTRA = 1,
  BFS = 2,
  DFS = 3,
  GREEDY_BFS = 4,
  JPS = 5,
  DSTAR_LITE = 6,
  THETA_STAR = 7,
  RRT = 8,
  PRM = 9
}

export interface NavixParams {
  gridRows: number
  gridCols: number
  cellSize: number
  backgroundColor: string
  gridLineColor: string
  showGridLines: boolean
  theme: 'light' | 'dark'
  heuristicType: 'manhattan' | 'euclidean' | 'chebyshev' | 'octile'
  allowDiagonal: boolean
  heuristicWeight: number
  animationSpeed: number
}

export interface HeatmapConfig {
  type: 'search' | 'path' | 'obstacle' | 'custom'
  gradient: string
  opacity: number
  blendMode: string
  realtimeUpdate: boolean
  showLegend: boolean
}