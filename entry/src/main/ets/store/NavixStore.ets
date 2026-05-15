import {
  GridPos,
  NodeType,
  MapData,
  LeftPanelState,
  RightPanelState,
  ToolType,
  AlgorithmType,
  AlgorithmSpec,
  HeuristicType,
  MapType,
  NavixParams,
  HeatmapConfig,
  VisualizationMode
} from '../models/MapTypes'
import { GridMapFromMapData, PathfindingOptions, PathfindingResult } from '../algorithms/PathfindingTypes'
import { AStarPathfinder } from '../algorithms/AStar'
import { DijkstraPathfinder } from '../algorithms/Dijkstra'
import { BFSPathfinder } from '../algorithms/BFS'
import { DFSPathfinder } from '../algorithms/DFS'
import { GreedyBFSPathfinder } from '../algorithms/GreedyBFS'
import { IDAStarPathfinder } from '../algorithms/IDAStar'

export class AlgorithmCompareResult {
  algoId: string
  implemented: boolean
  found: boolean
  cost: number
  exploredCount: number
  pathLength: number
  elapsedMs: number
  exploredMask: boolean[]
  pathMask: boolean[]

  constructor(algoId: string, implemented: boolean, found: boolean, cost: number, exploredCount: number, pathLength: number, elapsedMs: number, exploredMask: boolean[], pathMask: boolean[]) {
    this.algoId = algoId
    this.implemented = implemented
    this.found = found
    this.cost = cost
    this.exploredCount = exploredCount
    this.pathLength = pathLength
    this.elapsedMs = elapsedMs
    this.exploredMask = exploredMask
    this.pathMask = pathMask
  }
}

@ObservedV2
export class NavixStore {
  @Trace currentTool: ToolType | null = null
  @Trace currentAlgorithm: AlgorithmType | null = null
  @Trace selectedAlgorithms: AlgorithmSpec[] = []
  @Trace compareResults: AlgorithmCompareResult[] = []
  @Trace currentMapType: MapType = MapType.GRID

  @Trace leftPanelState: LeftPanelState = LeftPanelState.COLLAPSED
  @Trace rightPanelState: RightPanelState = RightPanelState.COLLAPSED

  @Trace mapData: MapData = this.createEmptyMap(20, 20)
  @Trace mapVersion: number = 0
  @Trace canvasZoomPercent: number = 100
  @Trace theme: 'light' | 'dark' = 'light'
  @Trace viewMode: 'edit' | 'present' = 'edit'
  @Trace settingsMenuOpen: boolean = false
  @Trace centerDialog: 'none' | 'settings' | 'theme' | 'view' = 'none'
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
  @Trace selectedCell: GridPos | null = null
  @Trace selectedCellMenuOpen: boolean = false
  @Trace searchedNodes: number = 0
  @Trace pathLength: number = 0
  @Trace elapsedTime: number = 0
  @Trace statusText: string = '就绪'
  @Trace searchSteps: GridPos[][] = []
  @Trace currentStep: number = 0
  @Trace obstacleCount: number = 0
  @Trace idaStarWeights: number[] = [0.5, 1.0, 1.5, 2.0]
  @Trace visualizationMode: VisualizationMode = VisualizationMode.NONE
  @Trace visualizationAlgorithmId: string | null = null
  @Trace visualizationClosedMask: boolean[] = []
  @Trace visualizationPathMask: boolean[] = []
  @Trace visualizationCurrentId: number = -1
  @Trace visualizationFound: boolean = false
  @Trace visualizationPlaying: boolean = false

  private visualizationExploredIds: number[] = []
  private visualizationPathIds: number[] = []
  private visualizationTimerId: number = -1

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

  private computeObstacleCount(): number {
    if (this.currentMapType !== MapType.GRID) {
      return 0
    }
    let count = 0
    for (let i = 0; i < this.mapData.rows; i++) {
      for (let j = 0; j < this.mapData.cols; j++) {
        if (this.mapData.grid[i][j] === NodeType.OBSTACLE) {
          count++
        }
      }
    }
    return count
  }

  getObstacleCount(): number {
    return this.obstacleCount
  }

  getMapTypeName(mapType: MapType): string {
    if (mapType === MapType.GRID) {
      return '栅格'
    }
    if (mapType === MapType.GRAPH) {
      return '图'
    }
    if (mapType === MapType.MAP_2D5) {
      return '2.5D'
    }
    if (mapType === MapType.MAP_3D) {
      return '3D'
    }
    return `${mapType}`
  }

  setTool(tool: ToolType): void {
    if (this.currentTool === tool) {
      this.currentTool = null
      this.selectedCell = null
      this.selectedCellMenuOpen = false
    } else {
      this.currentTool = tool
      if (tool !== ToolType.SELECT) {
        this.selectedCell = null
        this.selectedCellMenuOpen = false
      }
    }
  }

  openSettingsMenu(): void {
    this.settingsMenuOpen = true
  }

  closeSettingsMenu(): void {
    this.settingsMenuOpen = false
  }

  openCenterDialog(type: 'settings' | 'theme' | 'view'): void {
    this.centerDialog = type
  }

  closeCenterDialog(): void {
    this.centerDialog = 'none'
  }

  setTheme(theme: 'light' | 'dark'): void {
    this.theme = theme
    this.updateParams({ theme })
  }

  setViewMode(mode: 'edit' | 'present'): void {
    if (this.viewMode === mode) {
      return
    }
    this.viewMode = mode
    if (mode === 'present') {
      this.leftPanelState = LeftPanelState.COLLAPSED
      this.rightPanelState = RightPanelState.COLLAPSED
      this.currentTool = null
      this.selectedCell = null
      this.selectedCellMenuOpen = false
    }
  }

  setAlgorithm(algo: AlgorithmType): void {
    if (this.currentAlgorithm === algo) {
      this.currentAlgorithm = null
    } else {
      this.currentAlgorithm = algo
    }
  }

  formatHeuristicName(type: HeuristicType): string {
    if (type === 'manhattan') {
      return 'Manhattan'
    }
    if (type === 'euclidean') {
      return 'Euclidean'
    }
    if (type === 'chebyshev') {
      return 'Chebyshev'
    }
    return 'Octile'
  }

  formatWeight(weight: number): string {
    if (!Number.isFinite(weight)) {
      return '1.00'
    }
    return weight.toFixed(2)
  }

  createAStarSpec(heuristicType: HeuristicType): AlgorithmSpec {
    return { id: `astar-${heuristicType}`, type: AlgorithmType.ASTAR, heuristicType: heuristicType }
  }

  createIDAStarSpec(weight: number): AlgorithmSpec {
    const w = this.formatWeight(weight)
    return { id: `ida-${w}`, type: AlgorithmType.IDA_STAR, weight: Number(w) }
  }

  createSimpleSpec(type: AlgorithmType): AlgorithmSpec {
    return { id: `algo-${type}`, type: type }
  }

  addIDAStarWeight(weight: number): void {
    if (!Number.isFinite(weight) || weight <= 0 || weight > 10) {
      this.statusText = '权重范围: (0, 10]'
      return
    }
    const w = Number(this.formatWeight(weight))
    const prev = this.idaStarWeights
    for (let i = 0; i < prev.length; i++) {
      if (Math.abs(prev[i] - w) < 1e-6) {
        return
      }
    }
    const next: number[] = []
    for (let i = 0; i < prev.length; i++) {
      next.push(prev[i])
    }
    next.push(w)
    next.sort((a: number, b: number) => a - b)
    this.idaStarWeights = next
  }

  isSelectedAlgorithm(spec: AlgorithmSpec): boolean {
    const prev = this.selectedAlgorithms
    for (let i = 0; i < prev.length; i++) {
      if (prev[i].id === spec.id) {
        return true
      }
    }
    return false
  }

  toggleCompareAlgorithm(spec: AlgorithmSpec): void {
    const prev = this.selectedAlgorithms
    let idx = -1
    for (let i = 0; i < prev.length; i++) {
      if (prev[i].id === spec.id) {
        idx = i
        break
      }
    }
    if (idx >= 0) {
      const next: AlgorithmSpec[] = []
      for (let i = 0; i < prev.length; i++) {
        if (i !== idx) {
          next.push(prev[i])
        }
      }
      this.selectedAlgorithms = next
      this.compareResults = []
      return
    }
    if (prev.length >= 3) {
      this.statusText = '最多选择3个算法'
      return
    }
    const next: AlgorithmSpec[] = []
    for (let i = 0; i < prev.length; i++) {
      next.push(prev[i])
    }
    next.push(spec)
    this.selectedAlgorithms = next
    this.compareResults = []
  }

  getCompareResult(algoId: string): AlgorithmCompareResult | null {
    for (let i = 0; i < this.compareResults.length; i++) {
      const r = this.compareResults[i]
      if (r.algoId === algoId) {
        return r
      }
    }
    return null
  }

  getAlgorithmLabel(spec: AlgorithmSpec): string {
    if (spec.type === AlgorithmType.ASTAR) {
      const h = spec.heuristicType ? this.formatHeuristicName(spec.heuristicType) : this.formatHeuristicName(this.params.heuristicType)
      return `A* (${h})`
    }
    if (spec.type === AlgorithmType.IDA_STAR) {
      const w = spec.weight !== undefined ? this.formatWeight(spec.weight) : this.formatWeight(this.params.heuristicWeight)
      return `IDA* (w=${w})`
    }
    return this.getAlgorithmName(spec.type)
  }

  getAlgorithmName(algo: AlgorithmType): string {
    if (algo === AlgorithmType.ASTAR) {
      return 'A*'
    }
    if (algo === AlgorithmType.DIJKSTRA) {
      return 'Dijkstra'
    }
    if (algo === AlgorithmType.BFS) {
      return 'BFS'
    }
    if (algo === AlgorithmType.DFS) {
      return 'DFS'
    }
    if (algo === AlgorithmType.GREEDY_BFS) {
      return '贪心BFS'
    }
    if (algo === AlgorithmType.IDA_STAR) {
      return 'IDA*'
    }
    if (algo === AlgorithmType.DSTAR_LITE) {
      return 'D* Lite'
    }
    if (algo === AlgorithmType.THETA_STAR) {
      return 'Theta*'
    }
    if (algo === AlgorithmType.RRT) {
      return 'RRT'
    }
    if (algo === AlgorithmType.PRM) {
      return 'PRM'
    }
    return `${algo}`
  }

  private colorHash(id: string): number {
    let h = 0
    for (let i = 0; i < id.length; i++) {
      h = (h * 31 + id.charCodeAt(i)) >>> 0
    }
    return h
  }

  getAlgorithmPathColor(spec: AlgorithmSpec): string {
    if (spec.type === AlgorithmType.ASTAR) {
      if (spec.heuristicType === 'manhattan') {
        return '#3B82F6'
      }
      if (spec.heuristicType === 'euclidean') {
        return '#0EA5E9'
      }
      if (spec.heuristicType === 'chebyshev') {
        return '#6366F1'
      }
      return '#2563EB'
    }
    if (spec.type === AlgorithmType.DIJKSTRA) {
      return '#F97316'
    }
    if (spec.type === AlgorithmType.BFS) {
      return '#22C55E'
    }
    if (spec.type === AlgorithmType.DFS) {
      return '#A855F7'
    }
    if (spec.type === AlgorithmType.GREEDY_BFS) {
      return '#14B8A6'
    }
    if (spec.type === AlgorithmType.IDA_STAR) {
      const palette: string[] = ['#EF4444', '#DC2626', '#F43F5E', '#FB7185', '#E11D48']
      return palette[this.colorHash(spec.id) % palette.length]
    }
    return '#64748B'
  }

  getAlgorithmSpecById(id: string): AlgorithmSpec | null {
    for (let i = 0; i < this.selectedAlgorithms.length; i++) {
      const s = this.selectedAlgorithms[i]
      if (s.id === id) {
        return s
      }
    }
    return null
  }

  runCompare(): void {
    if (this.currentMapType !== MapType.GRID) {
      this.statusText = '当前仅支持栅格图对比'
      return
    }
    if (this.selectedAlgorithms.length === 0) {
      this.statusText = '请选择算法'
      return
    }
    if (!this.startPos || !this.endPos) {
      this.statusText = '请先设置起点与终点'
      return
    }

    const map = new GridMapFromMapData(this.mapData)

    const n = this.mapData.rows * this.mapData.cols
    const results: AlgorithmCompareResult[] = []

    for (let i = 0; i < this.selectedAlgorithms.length; i++) {
      const spec = this.selectedAlgorithms[i]
      let res: PathfindingResult | null = null
      let elapsedMs: number = 0
      const heuristicType = spec.type === AlgorithmType.ASTAR && spec.heuristicType ? spec.heuristicType : this.params.heuristicType
      const heuristicWeight = spec.type === AlgorithmType.IDA_STAR && spec.weight !== undefined ? spec.weight : this.params.heuristicWeight
      const opts: PathfindingOptions = {
        allowDiagonal: this.params.allowDiagonal,
        heuristicType: heuristicType,
        heuristicWeight: heuristicWeight
      }

      if (spec.type === AlgorithmType.ASTAR) {
        const t0 = Date.now()
        res = new AStarPathfinder().findPath(map, this.startPos, this.endPos, opts)
        elapsedMs = Date.now() - t0
      } else if (spec.type === AlgorithmType.DIJKSTRA) {
        const t0 = Date.now()
        res = new DijkstraPathfinder().findPath(map, this.startPos, this.endPos, opts)
        elapsedMs = Date.now() - t0
      } else if (spec.type === AlgorithmType.BFS) {
        const t0 = Date.now()
        res = new BFSPathfinder().findPath(map, this.startPos, this.endPos, opts)
        elapsedMs = Date.now() - t0
      } else if (spec.type === AlgorithmType.DFS) {
        const t0 = Date.now()
        res = new DFSPathfinder().findPath(map, this.startPos, this.endPos, opts)
        elapsedMs = Date.now() - t0
      } else if (spec.type === AlgorithmType.GREEDY_BFS) {
        const t0 = Date.now()
        res = new GreedyBFSPathfinder().findPath(map, this.startPos, this.endPos, opts)
        elapsedMs = Date.now() - t0
      } else if (spec.type === AlgorithmType.IDA_STAR) {
        const t0 = Date.now()
        res = new IDAStarPathfinder().findPath(map, this.startPos, this.endPos, opts)
        elapsedMs = Date.now() - t0
      } else {
        results.push(new AlgorithmCompareResult(spec.id, false, false, 0, 0, 0, 0, new Array<boolean>(n).fill(false), new Array<boolean>(n).fill(false)))
        continue
      }

      const exploredMask: boolean[] = new Array<boolean>(n).fill(false)
      const pathMask: boolean[] = new Array<boolean>(n).fill(false)

      for (let k = 0; k < res.explored.length; k++) {
        const p = res.explored[k]
        const id = p.row * this.mapData.cols + p.col
        if (id >= 0 && id < n) {
          exploredMask[id] = true
        }
      }
      for (let k = 0; k < res.path.length; k++) {
        const p = res.path[k]
        const id = p.row * this.mapData.cols + p.col
        if (id >= 0 && id < n) {
          pathMask[id] = true
        }
      }

      results.push(new AlgorithmCompareResult(spec.id, true, res.found, res.cost, res.explored.length, res.path.length, elapsedMs, exploredMask, pathMask))
    }

    this.compareResults = results
    this.statusText = '对比完成'
  }

  getCompareNodeType(algoId: string, row: number, col: number, base: NodeType): NodeType {
    const result = this.getCompareResult(algoId)
    if (!result) {
      return base
    }
    if (base === NodeType.START || base === NodeType.END || base === NodeType.OBSTACLE) {
      return base
    }
    const id = row * this.mapData.cols + col
    if (id < 0 || id >= result.pathMask.length) {
      return base
    }
    if (result.pathMask[id]) {
      return NodeType.PATH
    }
    if (result.exploredMask[id]) {
      return NodeType.EXPLORED
    }
    return base
  }

  setCanvasZoomPercent(percent: number): void {
    const safePercent = percent < 10 ? 10 : (percent > 300 ? 300 : percent)
    this.canvasZoomPercent = safePercent
  }

  setMapType(mapType: MapType): void {
    this.currentMapType = mapType
    this.obstacleCount = this.computeObstacleCount()
  }

  toggleLeftPanel(panelId: LeftPanelState) {
    if (this.leftPanelState === panelId) {
      this.leftPanelState = LeftPanelState.COLLAPSED
    } else {
      this.leftPanelState = panelId
    }
  }

  toggleRightPanel(state: RightPanelState): void {
    const prev = this.rightPanelState
    if (this.rightPanelState === state) {
      this.rightPanelState = RightPanelState.COLLAPSED
    } else {
      this.rightPanelState = state
    }
    if (prev === RightPanelState.VISUALIZATION && this.rightPanelState !== RightPanelState.VISUALIZATION) {
      this.clearVisualization()
    }
  }

  updateParams(partial: Partial<NavixParams>): void {
    const prev = this.params
    this.params = {
      gridRows: partial.gridRows !== undefined ? partial.gridRows : prev.gridRows,
      gridCols: partial.gridCols !== undefined ? partial.gridCols : prev.gridCols,
      cellSize: partial.cellSize !== undefined ? partial.cellSize : prev.cellSize,
      backgroundColor: partial.backgroundColor !== undefined ? partial.backgroundColor : prev.backgroundColor,
      gridLineColor: partial.gridLineColor !== undefined ? partial.gridLineColor : prev.gridLineColor,
      showGridLines: partial.showGridLines !== undefined ? partial.showGridLines : prev.showGridLines,
      theme: partial.theme !== undefined ? partial.theme : prev.theme,
      heuristicType: partial.heuristicType !== undefined ? partial.heuristicType : prev.heuristicType,
      allowDiagonal: partial.allowDiagonal !== undefined ? partial.allowDiagonal : prev.allowDiagonal,
      heuristicWeight: partial.heuristicWeight !== undefined ? partial.heuristicWeight : prev.heuristicWeight,
      animationSpeed: partial.animationSpeed !== undefined ? partial.animationSpeed : prev.animationSpeed
    }
  }

  updateHeatmapConfig(partial: Partial<HeatmapConfig>): void {
    const prev = this.heatmapConfig
    this.heatmapConfig = {
      type: partial.type !== undefined ? partial.type : prev.type,
      gradient: partial.gradient !== undefined ? partial.gradient : prev.gradient,
      opacity: partial.opacity !== undefined ? partial.opacity : prev.opacity,
      blendMode: partial.blendMode !== undefined ? partial.blendMode : prev.blendMode,
      realtimeUpdate: partial.realtimeUpdate !== undefined ? partial.realtimeUpdate : prev.realtimeUpdate,
      showLegend: partial.showLegend !== undefined ? partial.showLegend : prev.showLegend
    }
  }

  setStartPos(pos: GridPos): void {
    this.startPos = pos
  }

  setEndPos(pos: GridPos): void {
    this.endPos = pos
  }

  markMapChanged(): void {
    this.obstacleCount = this.computeObstacleCount()
    this.mapVersion++
    if (this.compareResults.length > 0) {
      this.compareResults = []
    }
    if (this.visualizationMode !== VisualizationMode.NONE) {
      this.clearVisualization()
    }
  }

  updateCell(row: number, col: number, type: NodeType): void {
    if (row >= 0 && row < this.mapData.rows && col >= 0 && col < this.mapData.cols) {
      if (this.mapData.grid[row][col] !== type) {
        this.mapData.grid[row][col] = type
        this.markMapChanged()
      }
    }
  }

  selectCell(row: number, col: number): void {
    if (this.currentMapType !== MapType.GRID) {
      return
    }
    if (row < 0 || row >= this.mapData.rows || col < 0 || col >= this.mapData.cols) {
      return
    }
    this.selectedCell = { row, col }
    this.selectedCellMenuOpen = false
  }

  clearSelectedCell(): void {
    this.selectedCell = null
    this.selectedCellMenuOpen = false
  }

  openSelectedCellMenu(): void {
    if (this.selectedCell === null) {
      return
    }
    if (this.currentTool !== ToolType.SELECT) {
      return
    }
    this.selectedCellMenuOpen = true
  }

  closeSelectedCellMenu(): void {
    this.selectedCellMenuOpen = false
  }

  setCellAsStart(row: number, col: number): void {
    if (this.currentMapType !== MapType.GRID) {
      return
    }
    if (row < 0 || row >= this.mapData.rows || col < 0 || col >= this.mapData.cols) {
      return
    }
    if (this.endPos && this.endPos.row === row && this.endPos.col === col) {
      this.endPos = null
    }
    if (this.startPos) {
      if (!(this.startPos.row === row && this.startPos.col === col)) {
        this.updateCell(this.startPos.row, this.startPos.col, NodeType.EMPTY)
      }
    }
    this.startPos = { row, col }
    this.updateCell(row, col, NodeType.START)
    this.selectCell(row, col)
  }

  setCellAsEnd(row: number, col: number): void {
    if (this.currentMapType !== MapType.GRID) {
      return
    }
    if (row < 0 || row >= this.mapData.rows || col < 0 || col >= this.mapData.cols) {
      return
    }
    if (this.startPos && this.startPos.row === row && this.startPos.col === col) {
      this.startPos = null
    }
    if (this.endPos) {
      if (!(this.endPos.row === row && this.endPos.col === col)) {
        this.updateCell(this.endPos.row, this.endPos.col, NodeType.EMPTY)
      }
    }
    this.endPos = { row, col }
    this.updateCell(row, col, NodeType.END)
    this.selectCell(row, col)
  }

  setCellAsObstacle(row: number, col: number): void {
    if (this.currentMapType !== MapType.GRID) {
      return
    }
    if (row < 0 || row >= this.mapData.rows || col < 0 || col >= this.mapData.cols) {
      return
    }
    const cur = this.mapData.grid[row][col]
    const normalized = (cur === NodeType.PATH || cur === NodeType.EXPLORED) ? NodeType.EMPTY : cur
    if (normalized === NodeType.START) {
      this.startPos = null
    }
    if (normalized === NodeType.END) {
      this.endPos = null
    }
    this.updateCell(row, col, NodeType.OBSTACLE)
    this.selectCell(row, col)
  }

  applyToolAt(row: number, col: number): void {
    if (this.currentMapType !== MapType.GRID) {
      return
    }
    if (this.currentTool === null || this.currentTool === ToolType.SELECT || this.currentTool === ToolType.RANDOM) {
      return
    }
    if (row < 0 || row >= this.mapData.rows || col < 0 || col >= this.mapData.cols) {
      return
    }

    const cur = this.mapData.grid[row][col]
    const normalized = (cur === NodeType.PATH || cur === NodeType.EXPLORED) ? NodeType.EMPTY : cur

    if (this.currentTool === ToolType.START) {
      if (this.endPos && this.endPos.row === row && this.endPos.col === col) {
        this.endPos = null
      }
      if (this.startPos) {
        if (!(this.startPos.row === row && this.startPos.col === col)) {
          this.updateCell(this.startPos.row, this.startPos.col, NodeType.EMPTY)
        }
      }
      this.startPos = { row, col }
      this.updateCell(row, col, NodeType.START)
      return
    }

    if (this.currentTool === ToolType.END) {
      if (this.startPos && this.startPos.row === row && this.startPos.col === col) {
        this.startPos = null
      }
      if (this.endPos) {
        if (!(this.endPos.row === row && this.endPos.col === col)) {
          this.updateCell(this.endPos.row, this.endPos.col, NodeType.EMPTY)
        }
      }
      this.endPos = { row, col }
      this.updateCell(row, col, NodeType.END)
      return
    }

    if (this.currentTool === ToolType.OBSTACLE) {
      if (normalized === NodeType.START) {
        this.startPos = null
      }
      if (normalized === NodeType.END) {
        this.endPos = null
      }
      this.updateCell(row, col, NodeType.OBSTACLE)
      return
    }

    if (this.currentTool === ToolType.ERASER) {
      if (normalized === NodeType.START) {
        this.startPos = null
      }
      if (normalized === NodeType.END) {
        this.endPos = null
      }
      this.updateCell(row, col, NodeType.EMPTY)
    }
  }

  updateMapData(data: MapData): void {
    this.mapData = data
    this.markMapChanged()
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
    this.pauseVisualizationPlayback()
    this.setVisualizationStep(this.currentStep + 1)
  }

  prevStep(): void {
    this.pauseVisualizationPlayback()
    this.setVisualizationStep(this.currentStep - 1)
  }

  toggleVisualizationPlayback(): void {
    if (this.visualizationMode === VisualizationMode.NONE) {
      return
    }
    if (this.visualizationPlaying) {
      this.pauseVisualizationPlayback()
      return
    }
    this.startVisualizationPlayback()
  }

  startVisualizationPlayback(): void {
    if (this.visualizationMode === VisualizationMode.NONE) {
      return
    }
    if (this.searchSteps.length <= 1) {
      return
    }
    if (this.currentStep >= this.searchSteps.length - 1) {
      this.setVisualizationStep(0)
    }
    this.visualizationPlaying = true
    if (this.visualizationTimerId >= 0) {
      clearInterval(this.visualizationTimerId)
      this.visualizationTimerId = -1
    }
    const interval = this.params.animationSpeed > 10 ? this.params.animationSpeed : 10
    this.visualizationTimerId = setInterval(() => {
      if (!this.visualizationPlaying) {
        return
      }
      if (this.searchSteps.length === 0) {
        this.pauseVisualizationPlayback()
        return
      }
      if (this.currentStep >= this.searchSteps.length - 1) {
        this.pauseVisualizationPlayback()
        return
      }
      this.setVisualizationStep(this.currentStep + 1)
    }, interval)
  }

  pauseVisualizationPlayback(): void {
    if (this.visualizationTimerId >= 0) {
      clearInterval(this.visualizationTimerId)
      this.visualizationTimerId = -1
    }
    this.visualizationPlaying = false
  }

  clearVisualization(): void {
    this.pauseVisualizationPlayback()
    this.visualizationMode = VisualizationMode.NONE
    this.visualizationAlgorithmId = null
    this.searchSteps = []
    this.currentStep = 0
    this.visualizationClosedMask = []
    this.visualizationPathMask = []
    this.visualizationCurrentId = -1
    this.visualizationFound = false
    this.visualizationExploredIds = []
    this.visualizationPathIds = []
  }

  restartVisualization(): void {
    if (this.visualizationMode === VisualizationMode.NONE || this.visualizationAlgorithmId === null) {
      return
    }
    const keepPlaying = this.visualizationPlaying
    this.pauseVisualizationPlayback()
    const spec = this.getAlgorithmSpecById(this.visualizationAlgorithmId)
    if (!spec) {
      this.clearVisualization()
      return
    }
    this.startVisualization(this.visualizationMode, spec)
    if (keepPlaying) {
      this.startVisualizationPlayback()
    }
  }

  startVisualization(mode: VisualizationMode, spec: AlgorithmSpec): void {
    if (this.currentMapType !== MapType.GRID) {
      this.statusText = '当前仅支持栅格图可视化'
      return
    }
    if (!this.startPos || !this.endPos) {
      this.statusText = '请先设置起点与终点'
      return
    }
    if (!(spec.type === AlgorithmType.ASTAR
      || spec.type === AlgorithmType.DIJKSTRA
      || spec.type === AlgorithmType.BFS
      || spec.type === AlgorithmType.DFS
      || spec.type === AlgorithmType.GREEDY_BFS
      || spec.type === AlgorithmType.IDA_STAR)) {
      this.statusText = '当前仅实现 A* / Dijkstra / BFS / DFS / 贪心BFS / IDA* 的可视化'
      return
    }

    const map = new GridMapFromMapData(this.mapData)
    const exploredIds: number[] = []
    const heuristicType = spec.type === AlgorithmType.ASTAR && spec.heuristicType ? spec.heuristicType : this.params.heuristicType
    const heuristicWeight = spec.type === AlgorithmType.IDA_STAR && spec.weight !== undefined ? spec.weight : this.params.heuristicWeight
    const opts: PathfindingOptions = {
      allowDiagonal: this.params.allowDiagonal,
      heuristicType: heuristicType,
      heuristicWeight: heuristicWeight,
      onStep: (currentId: number, _openIds: number[]) => {
        exploredIds.push(currentId)
      }
    }

    let res: PathfindingResult
    if (spec.type === AlgorithmType.ASTAR) {
      res = new AStarPathfinder().findPath(map, this.startPos, this.endPos, opts)
    } else if (spec.type === AlgorithmType.DIJKSTRA) {
      res = new DijkstraPathfinder().findPath(map, this.startPos, this.endPos, opts)
    } else if (spec.type === AlgorithmType.BFS) {
      res = new BFSPathfinder().findPath(map, this.startPos, this.endPos, opts)
    } else if (spec.type === AlgorithmType.DFS) {
      res = new DFSPathfinder().findPath(map, this.startPos, this.endPos, opts)
    } else {
      if (spec.type === AlgorithmType.GREEDY_BFS) {
        res = new GreedyBFSPathfinder().findPath(map, this.startPos, this.endPos, opts)
      } else {
        res = new IDAStarPathfinder().findPath(map, this.startPos, this.endPos, opts)
      }
    }

    const steps: GridPos[][] = []
    for (let i = 0; i < res.explored.length; i++) {
      steps.push([res.explored[i]])
    }
    if (exploredIds.length === 0) {
      for (let i = 0; i < res.explored.length; i++) {
        exploredIds.push(res.explored[i].row * this.mapData.cols + res.explored[i].col)
      }
    }

    const pathIds: number[] = []
    for (let i = 0; i < res.path.length; i++) {
      pathIds.push(res.path[i].row * this.mapData.cols + res.path[i].col)
    }

    this.visualizationMode = mode
    this.visualizationAlgorithmId = spec.id
    this.visualizationExploredIds = exploredIds
    this.visualizationPathIds = pathIds
    this.visualizationFound = res.found
    this.searchSteps = steps
    this.currentStep = 0

    this.ensureVisualizationMasks()
    this.setVisualizationStep(0)
    this.statusText = '可视化已生成'
  }

  ensureVisualizationMasks(): void {
    const n = this.mapData.rows * this.mapData.cols
    if (this.visualizationClosedMask.length !== n) {
      this.visualizationClosedMask = new Array<boolean>(n).fill(false)
    }
    if (this.visualizationPathMask.length !== n) {
      this.visualizationPathMask = new Array<boolean>(n).fill(false)
    }
    for (let i = 0; i < n; i++) {
      this.visualizationClosedMask[i] = false
      this.visualizationPathMask[i] = false
    }
    for (let i = 0; i < this.visualizationPathIds.length; i++) {
      const id = this.visualizationPathIds[i]
      if (id >= 0 && id < n) {
        this.visualizationPathMask[id] = true
      }
    }
  }

  setVisualizationStep(step: number): void {
    if (this.visualizationMode === VisualizationMode.NONE) {
      if (step < 0) {
        this.currentStep = 0
      } else {
        this.currentStep = step
      }
      return
    }
    const max = this.searchSteps.length > 0 ? this.searchSteps.length - 1 : 0
    const safe = step < 0 ? 0 : (step > max ? max : step)
    if (this.searchSteps.length === 0) {
      this.currentStep = 0
      return
    }

    const prev = this.currentStep
    this.currentStep = safe

    const n = this.mapData.rows * this.mapData.cols
    if (this.visualizationClosedMask.length !== n) {
      this.ensureVisualizationMasks()
    }

    if (safe < prev) {
      for (let i = 0; i < n; i++) {
        this.visualizationClosedMask[i] = false
      }
      for (let i = 0; i <= safe && i < this.visualizationExploredIds.length; i++) {
        const id = this.visualizationExploredIds[i]
        if (id >= 0 && id < n) {
          this.visualizationClosedMask[id] = true
        }
      }
    } else {
      for (let i = prev + 1; i <= safe && i < this.visualizationExploredIds.length; i++) {
        const id = this.visualizationExploredIds[i]
        if (id >= 0 && id < n) {
          this.visualizationClosedMask[id] = true
        }
      }
    }

    this.visualizationCurrentId = safe < this.visualizationExploredIds.length ? this.visualizationExploredIds[safe] : -1
  }

  generateRandomObstacles(): void {
    const obstacleDensity = 0.25
    for (let i = 0; i < this.mapData.rows; i++) {
      for (let j = 0; j < this.mapData.cols; j++) {
        const cur = this.mapData.grid[i][j]
        if (cur === NodeType.START || cur === NodeType.END) {
          continue
        }
        this.mapData.grid[i][j] = Math.random() < obstacleDensity ? NodeType.OBSTACLE : NodeType.EMPTY
      }
    }
    this.markMapChanged()
  }

  resizeMap(rows: number, cols: number): void {
    const safeRows = rows > 0 ? rows : 20
    const safeCols = cols > 0 ? cols : 20
    this.mapData = this.createEmptyMap(safeRows, safeCols)
    this.markMapChanged()
    this.updateParams({ gridRows: safeRows, gridCols: safeCols })
    this.statusText = `地图大小: ${safeCols}×${safeRows}`
  }

  generateEmptyMap(rows: number = this.mapData.rows, cols: number = this.mapData.cols): void {
    const safeRows = rows > 0 ? rows : 20
    const safeCols = cols > 0 ? cols : 20
    this.mapData = this.createEmptyMap(safeRows, safeCols)
    this.markMapChanged()
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
    this.markMapChanged()
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
    this.markMapChanged()
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
    this.markMapChanged()
    this.updateParams({ gridRows: safeRows, gridCols: safeCols })
  }

  generateRandomMap(rows: number = this.mapData.rows, cols: number = this.mapData.cols): void {
    const safeRows = rows > 0 ? rows : 20
    const safeCols = cols > 0 ? cols : 20
    this.mapData = this.createEmptyMap(safeRows, safeCols)
    this.updateParams({ gridRows: safeRows, gridCols: safeCols })
    this.generateRandomObstacles()
  }

  generateGraphMap(rows: number = this.mapData.rows, cols: number = this.mapData.cols): void {
    const safeRows = rows > 0 ? rows : 20
    const safeCols = cols > 0 ? cols : 20
    this.mapData = this.createEmptyMap(safeRows, safeCols)
    this.updateParams({ gridRows: safeRows, gridCols: safeCols })
    
    for (let i = 0; i < safeRows; i++) {
      for (let j = 0; j < safeCols; j++) {
        if (Math.random() < 0.3) {
          this.mapData.grid[i][j] = NodeType.OBSTACLE
        }
      }
    }
    this.markMapChanged()
  }

  generate2D5Map(rows: number = this.mapData.rows, cols: number = this.mapData.cols): void {
    const safeRows = rows > 0 ? rows : 20
    const safeCols = cols > 0 ? cols : 20
    this.mapData = this.createEmptyMap(safeRows, safeCols)
    this.updateParams({ gridRows: safeRows, gridCols: safeCols })
    
    for (let i = 0; i < safeRows; i++) {
      for (let j = 0; j < safeCols; j++) {
        const height = Math.floor(Math.random() * 5)
        if (height > 3) {
          this.mapData.grid[i][j] = NodeType.OBSTACLE
        }
      }
    }
    this.markMapChanged()
  }

  generate3DMap(rows: number = this.mapData.rows, cols: number = this.mapData.cols): void {
    const safeRows = rows > 0 ? rows : 20
    const safeCols = cols > 0 ? cols : 20
    this.mapData = this.createEmptyMap(safeRows, safeCols)
    this.updateParams({ gridRows: safeRows, gridCols: safeCols })
    
    for (let i = 0; i < safeRows; i++) {
      for (let j = 0; j < safeCols; j++) {
        const noise = Math.sin(i * 0.3) * Math.cos(j * 0.3) * Math.random() * 0.5 + Math.random() * 0.5
        if (noise > 0.7) {
          this.mapData.grid[i][j] = NodeType.OBSTACLE
        }
      }
    }
    this.markMapChanged()
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
