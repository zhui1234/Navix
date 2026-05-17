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
  MAP_SETTINGS = 1,
  VISUALIZATION = 2,
  HEATMAP = 3
}

export enum ToolType {
  SELECT = 0,
  START = 1,
  END = 2,
  OBSTACLE = 3,
  ERASER = 4,
  RANDOM_OBSTACLE = 5,
  RANDOM_STARTING = 6,
  RANDOM_FINISHING = 7
}

export enum AlgorithmType {
  ASTAR = 0,
  DIJKSTRA = 1,
  BFS = 2,
  DFS = 3,
  GREEDY_BFS = 4,
  IDA_STAR = 5,
  DSTAR_LITE = 6,
  THETA_STAR = 7,
  RRT = 8,
  PRM = 9
}

export enum MapType {
  GRID = 0,
  GRAPH = 1,
  MAP_2D5 = 2,
  MAP_3D = 3
}

export enum VisualizationMode {
  NONE = 0,
  TIMELINE = 1,
  OPEN_CLOSED = 2
}

export type HeuristicType = 'manhattan' | 'euclidean' | 'chebyshev' | 'octile'

export interface AlgorithmSpec {
  id: string
  type: AlgorithmType
  heuristicType?: HeuristicType
  weight?: number
}

export interface NavixParams {
  gridRows: number
  gridCols: number
  cellSize: number
  backgroundColor: string
  gridLineColor: string
  showGridLines: boolean
  theme: 'light' | 'dark'
  heuristicType: HeuristicType
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
