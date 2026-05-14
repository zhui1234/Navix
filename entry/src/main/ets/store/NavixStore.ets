import {
  GridPos,
  NodeType,
  MapData,
  LeftPanelState,
  RightPanelState,
  ToolType,
  AlgorithmType,
  NavixParams,
  HeatmapConfig
} from '../models/MapTypes'

@ObservedV2
export class NavixStore {
  @Trace currentTool: ToolType | null = null
  @Trace currentAlgorithm: AlgorithmType | null = null

  @Trace leftPanelState: LeftPanelState = LeftPanelState.COLLAPSED
  @Trace rightPanelState: RightPanelState = RightPanelState.COLLAPSED

  @Trace mapData: MapData = this.createEmptyMap(20, 20)
  @Trace params: NavixParams = {
    gridRows: 20,
    gridCols: 20,
    cellSize: 30,
    backgroundColor: '',
    gridLineColor: '',
    showGridLines: true,
    theme: 'light',
    heuristicType: 'manhattan',
    allowDiagonal: false,
    heuristicWeight: 1.0,
    animationSpeed: 50
  }
  @Trace heatmapConfig: HeatmapConfig = {
    type: 'search',
    gradient: 'blue-green-red',
    opacity: 0.5,
    blendMode: 'normal',
    realtimeUpdate: true,
    showLegend: true
  }
  @Trace startPos: GridPos | null = null
  @Trace endPos: GridPos | null = null
  @Trace searchedNodes: number = 0
  @Trace pathLength: number = 0
  @Trace elapsedTime: number = 0
  @Trace statusText: string = '就绪'
  @Trace searchSteps: GridPos[][] = []
  @Trace currentStep: number = 0

  private createEmptyMap(rows: number, cols: number): MapData {
    const grid: NodeType[][] = []
    for (let i = 0; i < rows; i++) {
      grid[i] = []
      for (let j = 0; j < cols; j++) {
        grid[i][j] = NodeType.EMPTY
      }
    }
    return { grid, rows, cols }
  }

  setTool(tool: ToolType): void {
    if (this.currentTool === tool) {
      this.currentTool = null
    } else {
      this.currentTool = tool
    }
  }

  setAlgorithm(algo: AlgorithmType): void {
    if (this.currentAlgorithm === algo) {
      this.currentAlgorithm = null
    } else {
      this.currentAlgorithm = algo
    }
  }

  toggleLeftPanel(panelId: LeftPanelState) {
    if (this.leftPanelState === panelId) {
      this.leftPanelState = LeftPanelState.COLLAPSED
    } else {
      this.leftPanelState = panelId
    }
  }

  toggleRightPanel(state: RightPanelState): void {
    if (this.rightPanelState === state) {
      this.rightPanelState = RightPanelState.COLLAPSED
    } else {
      this.rightPanelState = state
    }
  }

  updateParams(partial: Partial<NavixParams>): void {
    if (partial.gridRows !== undefined) this.params.gridRows = partial.gridRows
    if (partial.gridCols !== undefined) this.params.gridCols = partial.gridCols
    if (partial.cellSize !== undefined) this.params.cellSize = partial.cellSize
    if (partial.backgroundColor !== undefined) this.params.backgroundColor = partial.backgroundColor
    if (partial.gridLineColor !== undefined) this.params.gridLineColor = partial.gridLineColor
    if (partial.showGridLines !== undefined) this.params.showGridLines = partial.showGridLines
    if (partial.theme !== undefined) this.params.theme = partial.theme
    if (partial.heuristicType !== undefined) this.params.heuristicType = partial.heuristicType
    if (partial.allowDiagonal !== undefined) this.params.allowDiagonal = partial.allowDiagonal
    if (partial.heuristicWeight !== undefined) this.params.heuristicWeight = partial.heuristicWeight
    if (partial.animationSpeed !== undefined) this.params.animationSpeed = partial.animationSpeed
  }

  updateHeatmapConfig(partial: Partial<HeatmapConfig>): void {
    if (partial.type !== undefined) this.heatmapConfig.type = partial.type
    if (partial.gradient !== undefined) this.heatmapConfig.gradient = partial.gradient
    if (partial.opacity !== undefined) this.heatmapConfig.opacity = partial.opacity
    if (partial.blendMode !== undefined) this.heatmapConfig.blendMode = partial.blendMode
    if (partial.realtimeUpdate !== undefined) this.heatmapConfig.realtimeUpdate = partial.realtimeUpdate
    if (partial.showLegend !== undefined) this.heatmapConfig.showLegend = partial.showLegend
  }

  setStartPos(pos: GridPos): void {
    this.startPos = pos
  }

  setEndPos(pos: GridPos): void {
    this.endPos = pos
  }

  updateCell(row: number, col: number, type: NodeType): void {
    if (row >= 0 && row < this.mapData.rows && col >= 0 && col < this.mapData.cols) {
      this.mapData.grid[row][col] = type
    }
  }

  updateMapData(data: MapData): void {
    this.mapData = data
  }

  resetSearchState(): void {
    this.searchedNodes = 0
    this.pathLength = 0
    this.elapsedTime = 0
    this.statusText = '就绪'
    this.searchSteps = []
    this.currentStep = 0
  }

  updateSearchProgress(explored: number, path: number, time: number): void {
    this.searchedNodes = explored
    this.pathLength = path
    this.elapsedTime = time
  }

  setSearchSteps(steps: GridPos[][]): void {
    this.searchSteps = steps
    this.currentStep = 0
  }

  nextStep(): void {
    if (this.currentStep < this.searchSteps.length - 1) {
      this.currentStep++
    }
  }

  prevStep(): void {
    if (this.currentStep > 0) {
      this.currentStep--
    }
  }

  generateRandomObstacles(): void {
    const obstacleDensity = 0.25
    for (let i = 0; i < this.mapData.rows; i++) {
      for (let j = 0; j < this.mapData.cols; j++) {
        if (Math.random() < obstacleDensity) {
          this.mapData.grid[i][j] = NodeType.OBSTACLE
        }
      }
    }
  }
}

export const navixStore = new NavixStore()
