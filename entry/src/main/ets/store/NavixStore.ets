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
  @Trace theme: 'light' | 'dark' = 'light'
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

  resizeMap(rows: number, cols: number): void {
    const safeRows = rows > 0 ? rows : 20
    const safeCols = cols > 0 ? cols : 20
    this.mapData = this.createEmptyMap(safeRows, safeCols)
    this.updateParams({ gridRows: safeRows, gridCols: safeCols })
  }

  generateEmptyMap(rows: number = this.mapData.rows, cols: number = this.mapData.cols): void {
    const safeRows = rows > 0 ? rows : 20
    const safeCols = cols > 0 ? cols : 20
    this.mapData = this.createEmptyMap(safeRows, safeCols)
    this.updateParams({ gridRows: safeRows, gridCols: safeCols })
  }

  generateMazeMap(rows: number = this.mapData.rows, cols: number = this.mapData.cols): void {
    const safeRows = rows > 0 ? rows : 20
    const safeCols = cols > 0 ? cols : 20
    const grid: NodeType[][] = []
    for (let i = 0; i < safeRows; i++) {
      grid[i] = []
      for (let j = 0; j < safeCols; j++) {
        grid[i][j] = NodeType.OBSTACLE
      }
    }

    const carve = (x: number, y: number) => {
      grid[y][x] = NodeType.EMPTY
      const directions = [
        [0, -2], [0, 2], [-2, 0], [2, 0]
      ].sort(() => Math.random() - 0.5)

      for (let i = 0; i < directions.length; i++) {
        const dx = directions[i][0]
        const dy = directions[i][1]
        const nx = x + dx
        const ny = y + dy
        if (ny > 0 && ny < safeRows - 1 && nx > 0 && nx < safeCols - 1 && grid[ny][nx] === NodeType.OBSTACLE) {
          grid[y + dy / 2][x + dx / 2] = NodeType.EMPTY
          carve(nx, ny)
        }
      }
    }

    const startX = 1
    const startY = 1
    carve(startX, startY)
    this.mapData = { grid, rows: safeRows, cols: safeCols }
    this.updateParams({ gridRows: safeRows, gridCols: safeCols })
  }

  generateRoomsMap(rows: number = this.mapData.rows, cols: number = this.mapData.cols): void {
    const safeRows = rows > 0 ? rows : 20
    const safeCols = cols > 0 ? cols : 20
    const grid: NodeType[][] = []
    for (let i = 0; i < safeRows; i++) {
      grid[i] = []
      for (let j = 0; j < safeCols; j++) {
        grid[i][j] = NodeType.EMPTY
      }
    }

    for (let i = 0; i < safeCols; i++) {
      grid[Math.floor(safeRows / 3)][i] = NodeType.OBSTACLE
      grid[Math.floor(safeRows * 2 / 3)][i] = NodeType.OBSTACLE
    }
    for (let i = 0; i < safeRows; i++) {
      grid[i][Math.floor(safeCols / 3)] = NodeType.OBSTACLE
      grid[i][Math.floor(safeCols * 2 / 3)] = NodeType.OBSTACLE
    }

    const doors = [
      [Math.floor(safeRows / 3), Math.floor(safeCols / 6)],
      [Math.floor(safeRows / 3), Math.floor(safeCols / 2)],
      [Math.floor(safeRows / 3), Math.floor(safeCols * 5 / 6)],
      [Math.floor(safeRows * 2 / 3), Math.floor(safeCols / 6)],
      [Math.floor(safeRows * 2 / 3), Math.floor(safeCols / 2)],
      [Math.floor(safeRows * 2 / 3), Math.floor(safeCols * 5 / 6)],
      [Math.floor(safeRows / 6), Math.floor(safeCols / 3)],
      [Math.floor(safeRows / 2), Math.floor(safeCols / 3)],
      [Math.floor(safeRows * 5 / 6), Math.floor(safeCols / 3)],
      [Math.floor(safeRows / 6), Math.floor(safeCols * 2 / 3)],
      [Math.floor(safeRows / 2), Math.floor(safeCols * 2 / 3)],
      [Math.floor(safeRows * 5 / 6), Math.floor(safeCols * 2 / 3)]
    ]

    for (let i = 0; i < doors.length; i++) {
      const r = doors[i][0]
      const c = doors[i][1]
      if (r >= 0 && r < safeRows && c >= 0 && c < safeCols) {
        grid[r][c] = NodeType.EMPTY
      }
    }

    this.mapData = { grid, rows: safeRows, cols: safeCols }
    this.updateParams({ gridRows: safeRows, gridCols: safeCols })
  }

  generateSymmetricMap(rows: number = this.mapData.rows, cols: number = this.mapData.cols): void {
    const safeRows = rows > 0 ? rows : 20
    const safeCols = cols > 0 ? cols : 20
    const grid: NodeType[][] = []
    for (let i = 0; i < safeRows; i++) {
      grid[i] = []
      for (let j = 0; j < safeCols; j++) {
        grid[i][j] = NodeType.EMPTY
      }
    }

    const addObstacle = (r: number, c: number) => {
      if (r >= 0 && r < safeRows && c >= 0 && c < safeCols) {
        grid[r][c] = NodeType.OBSTACLE
        grid[r][safeCols - 1 - c] = NodeType.OBSTACLE
        grid[safeRows - 1 - r][c] = NodeType.OBSTACLE
        grid[safeRows - 1 - r][safeCols - 1 - c] = NodeType.OBSTACLE
      }
    }

    for (let i = 2; i < safeRows - 2; i += 3) {
      for (let j = 2; j < safeCols / 2 - 2; j += 4) {
        addObstacle(i, j)
      }
    }

    this.mapData = { grid, rows: safeRows, cols: safeCols }
    this.updateParams({ gridRows: safeRows, gridCols: safeCols })
  }

  generateRandomMap(rows: number = this.mapData.rows, cols: number = this.mapData.cols): void {
    const safeRows = rows > 0 ? rows : 20
    const safeCols = cols > 0 ? cols : 20
    this.mapData = this.createEmptyMap(safeRows, safeCols)
    this.updateParams({ gridRows: safeRows, gridCols: safeCols })
    this.generateRandomObstacles()
  }

  toggleTheme(): void {
    const newTheme = this.theme === 'light' ? 'dark' : 'light'
    this.theme = newTheme
    this.updateParams({ theme: newTheme })
  }

  getColor(colorName: string): string {
    const lightColors: Record<string, string> = {
      'navix_bg_primary': '#F5F5F5',
      'navix_bg_canvas': '#FFFFFF',
      'navix_bg_toolbar': '#F0F0F0',
      'navix_bg_panel': '#EBEBEB',
      'navix_text_primary': '#1A1A1A',
      'navix_text_secondary': '#666666',
      'navix_border_color': '#D0D0D0',
      'navix_icon_color': '#333333',
      'navix_grid_line': '#DDDDDD',
      'navix_accent_highlight': '#007AFF',
      'navix_node_start': '#4CAF50',
      'navix_node_end': '#F44336',
      'navix_node_obstacle': '#424242',
      'navix_node_explored': '#90CAF9',
      'navix_node_path': '#FFEB3B',
      'navix_button_active': '#007AFF',
      'navix_button_inactive': '#BDBDBD'
    }
    
    const darkColors: Record<string, string> = {
      'navix_bg_primary': '#181818',
      'navix_bg_canvas': '#1A1A1A',
      'navix_bg_toolbar': '#222222',
      'navix_bg_panel': '#2A2A2A',
      'navix_text_primary': '#E0E0E0',
      'navix_text_secondary': '#999999',
      'navix_border_color': '#404040',
      'navix_icon_color': '#CCCCCC',
      'navix_grid_line': '#3A3A3A',
      'navix_accent_highlight': '#0A84FF',
      'navix_node_start': '#66BB6A',
      'navix_node_end': '#EF5350',
      'navix_node_obstacle': '#757575',
      'navix_node_explored': '#42A5F5',
      'navix_node_path': '#FFEE58',
      'navix_button_active': '#0A84FF',
      'navix_button_inactive': '#616161'
    }
    
    const colors = this.theme === 'light' ? lightColors : darkColors
    return colors[colorName] || '#000000'
  }
}

export const navixStore = new NavixStore()
