import { NavixStore, navixStore } from '../store/NavixStore'
import { NodeType, ToolType, MapType, AlgorithmSpec, VisualizationMode } from '../models/MapTypes'

const MINIMAP_SIZE: number = 120
const MINIMAP_CELLS: number = 40
const SCROLL_BAR_SIZE: number = 10
const MINIMAP_MARGIN: number = 16

interface MinimapViewRect {
  x: number
  y: number
  w: number
  h: number
}

function createIndices(count: number): number[] {
  const res: number[] = []
  for (let i = 0; i < count; i++) {
    res.push(i)
  }
  return res
}

const MINIMAP_INDICES: number[] = createIndices(MINIMAP_CELLS)

@ComponentV2
export struct MainCanvas {
  @Local store: NavixStore = navixStore
  @Param algorithm: string | null = null
  private horizontalScroller: Scroller = new Scroller()
  private verticalScroller: Scroller = new Scroller()
  @Local private painting: boolean = false
  @Local private lastPaintKey: string = ''
  @Local private canvasWidth: number = 0
  @Local private canvasHeight: number = 0
  @Local private scrollX: number = 0
  @Local private scrollY: number = 0
  @Local private minimapX: number = 0
  @Local private minimapY: number = 0
  @Local private minimapInitialized: boolean = false
  @Local private minimapDragging: boolean = false
  @Local private minimapDragStartX: number = 0
  @Local private minimapDragStartY: number = 0

  getScaledCellSize(): number {
    return Math.round(this.store.params.cellSize * this.store.canvasZoomPercent / 100)
  }

  canEditGrid(): boolean {
    return this.store.currentMapType === MapType.GRID
      && this.store.currentTool !== null
      && this.store.currentTool !== ToolType.SELECT
      && this.store.currentTool !== ToolType.RANDOM
      && this.algorithm === null
  }

  getDisplayNodeType(row: number, col: number, base: NodeType): NodeType {
    if (this.algorithm === null) {
      return base
    }
    return this.store.getCompareNodeType(this.algorithm, row, col, base)
  }

  isCellSelected(row: number, col: number): boolean {
    const s = this.store.selectedCell
    return this.store.currentTool === ToolType.SELECT && this.algorithm === null && s !== null && s.row === row && s.col === col
  }

  getComparePathColors(row: number, col: number, base: NodeType): string[] {
    if (this.algorithm !== null) {
      return []
    }
    if (this.store.compareResults.length === 0) {
      return []
    }
    if (base === NodeType.START || base === NodeType.END || base === NodeType.OBSTACLE) {
      return []
    }
    const id = row * this.store.mapData.cols + col
    const colors: string[] = []
    for (let i = 0; i < this.store.selectedAlgorithms.length; i++) {
      const spec = this.store.selectedAlgorithms[i]
      const result = this.store.getCompareResult(spec.id)
      if (!result) {
        continue
      }
      if (id >= 0 && id < result.pathMask.length && result.pathMask[id]) {
        colors.push(this.store.getAlgorithmPathColor(spec))
      }
    }
    return colors
  }

  @Builder
  ComparePathOverlay(row: number, col: number, base: NodeType) {
    if (this.store.visualizationMode === VisualizationMode.NONE) {
      if (this.getComparePathColors(row, col, base).length > 0) {
        Row({ space: 0 }) {
          ForEach(this.getComparePathColors(row, col, base), (color: string, _idx: number) => {
            Column()
              .layoutWeight(1)
              .height('100%')
              .backgroundColor(color)
              .opacity(0.55)
          }, (_color: string, idx: number) => `${this.store.mapVersion}-${row}-${col}-${idx}`)
        }
        .width('100%')
        .height('100%')
      }
    }
  }

  shouldShowVisualization(): boolean {
    return this.algorithm === null && this.store.visualizationMode !== VisualizationMode.NONE
  }

  shouldShowVisualizationPath(): boolean {
    if (!this.shouldShowVisualization()) {
      return false
    }
    if (!this.store.visualizationFound) {
      return false
    }
    if (this.store.visualizationMode !== VisualizationMode.TIMELINE) {
      return false
    }
    if (this.store.searchSteps.length === 0) {
      return false
    }
    return this.store.currentStep >= this.store.searchSteps.length - 1
  }

  getVisualizationOverlayColor(row: number, col: number, base: NodeType): ResourceColor | null {
    if (!this.shouldShowVisualization()) {
      return null
    }
    if (base === NodeType.START || base === NodeType.END || base === NodeType.OBSTACLE) {
      return null
    }
    const id = row * this.store.mapData.cols + col
    if (id < 0 || id >= this.store.mapData.rows * this.store.mapData.cols) {
      return null
    }
    if (this.shouldShowVisualizationPath() && id < this.store.visualizationPathMask.length && this.store.visualizationPathMask[id]) {
      return this.store.getColor('navix_node_path')
    }
    if (id === this.store.visualizationCurrentId) {
      return this.store.getColor('navix_accent_highlight')
    }
    if (id < this.store.visualizationClosedMask.length && this.store.visualizationClosedMask[id]) {
      return this.store.getColor('navix_node_explored')
    }
    return null
  }

  getVisualizationOverlayOpacity(row: number, col: number, base: NodeType): number {
    const color = this.getVisualizationOverlayColor(row, col, base)
    if (color === null) {
      return 0
    }
    const id = row * this.store.mapData.cols + col
    if (this.shouldShowVisualizationPath() && id < this.store.visualizationPathMask.length && this.store.visualizationPathMask[id]) {
      return 0.6
    }
    if (id === this.store.visualizationCurrentId) {
      return 0.55
    }
    return 0.35
  }

  @Builder
  VisualizationOverlay(row: number, col: number, base: NodeType) {
    if (this.shouldShowVisualization()) {
      if (this.getVisualizationOverlayColor(row, col, base) !== null) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(this.getVisualizationOverlayColor(row, col, base)!)
          .opacity(this.getVisualizationOverlayOpacity(row, col, base))
      }
    }
  }

  shouldShowLegend(): boolean {
    return this.algorithm === null
      && this.store.selectedAlgorithms.length > 0
      && this.store.visualizationMode === VisualizationMode.NONE
  }

  formatElapsed(ms: number): string {
    if (!Number.isFinite(ms) || ms < 0) {
      return '0ms'
    }
    if (ms >= 1000) {
      return `${(ms / 1000).toFixed(2)}s`
    }
    return `${Math.round(ms)}ms`
  }

  getLegendOverallStatus(): string {
    if (!this.store.startPos || !this.store.endPos) {
      return '未设置起点/终点'
    }
    if (this.store.compareResults.length === 0) {
      return '未运行'
    }
    for (let i = 0; i < this.store.compareResults.length; i++) {
      if (this.store.compareResults[i].implemented) {
        return '已运行'
      }
    }
    return '未实现'
  }

  getLegendPathText(algo: AlgorithmSpec): string {
    if (!this.store.startPos || !this.store.endPos) {
      return '-'
    }
    const result = this.store.getCompareResult(algo.id)
    if (!result) {
      return '-'
    }
    if (!result.implemented) {
      return '未实现'
    }
    if (!result.found) {
      return '无'
    }
    return `${result.pathLength}`
  }

  getLegendExploredText(algo: AlgorithmSpec): string {
    if (!this.store.startPos || !this.store.endPos) {
      return '-'
    }
    const result = this.store.getCompareResult(algo.id)
    if (!result || !result.implemented) {
      return '-'
    }
    return `${result.exploredCount}`
  }

  getLegendTimeText(algo: AlgorithmSpec): string {
    if (!this.store.startPos || !this.store.endPos) {
      return '-'
    }
    const result = this.store.getCompareResult(algo.id)
    if (!result || !result.implemented) {
      return '-'
    }
    return this.formatElapsed(result.elapsedMs)
  }

  @Builder
  LegendOverlay() {
    if (this.shouldShowLegend()) {
      Column({ space: 8 }) {
        Row() {
          Text('路径图例')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.store.getColor('navix_text_primary'))

          Blank()

          Text(this.getLegendOverallStatus())
            .fontSize(10)
            .fontColor(this.store.getColor('navix_text_secondary'))
        }
        .width('100%')

        Row() {
          Text('算法')
            .fontSize(10)
            .fontColor(this.store.getColor('navix_text_secondary'))
            .layoutWeight(1)

          Text('路径')
            .fontSize(10)
            .fontColor(this.store.getColor('navix_text_secondary'))
            .width(42)
            .textAlign(TextAlign.Center)

          Text('探索')
            .fontSize(10)
            .fontColor(this.store.getColor('navix_text_secondary'))
            .width(52)
            .textAlign(TextAlign.Center)

          Text('时间')
            .fontSize(10)
            .fontColor(this.store.getColor('navix_text_secondary'))
            .width(56)
            .textAlign(TextAlign.Center)
        }
        .width('100%')

        Divider()
          .color(this.store.getColor('navix_border_color'))

        ForEach(this.store.selectedAlgorithms, (algo: AlgorithmSpec) => {
          Column({ space: 6 }) {
            Row({ space: 8 }) {
              Row({ space: 6 }) {
                Column()
                  .width(10)
                  .height(10)
                  .borderRadius(2)
                  .backgroundColor(this.store.getAlgorithmPathColor(algo))

                Text(this.store.getAlgorithmLabel(algo))
                  .fontSize(11)
                  .fontColor(this.store.getColor('navix_text_primary'))
              }
              .layoutWeight(1)

              Text(this.getLegendPathText(algo))
                .fontSize(11)
                .fontColor(this.store.getColor('navix_text_primary'))
                .width(42)
                .textAlign(TextAlign.Center)

              Text(this.getLegendExploredText(algo))
                .fontSize(11)
                .fontColor(this.store.getColor('navix_text_primary'))
                .width(52)
                .textAlign(TextAlign.Center)

              Text(this.getLegendTimeText(algo))
                .fontSize(11)
                .fontColor(this.store.getColor('navix_text_primary'))
                .width(56)
                .textAlign(TextAlign.Center)
            }
            .width('100%')

            Divider()
              .color(this.store.getColor('navix_border_color'))
          }
          .width('100%')
        }, (algo: AlgorithmSpec) => `${algo.id}`)
      }
      .alignItems(HorizontalAlign.Start)
      .width(260)
      .padding(10)
      .borderRadius(6)
      .border({ width: 1, color: this.store.getColor('navix_border_color') })
      .backgroundColor(this.store.getColor('navix_bg_canvas'))
      .shadow({ radius: 12, color: '#33000000', offsetX: 0, offsetY: 4 })
      .clip(true)
      .position({ x: MINIMAP_MARGIN, y: MINIMAP_MARGIN })
    }
  }

  applyAtPoint(x: number, y: number): void {
    const size = this.getScaledCellSize()
    if (size <= 0) {
      return
    }
    const offsetX = this.horizontalScroller.currentOffset().xOffset
    const offsetY = this.verticalScroller.currentOffset().yOffset
    const col = Math.floor((x + offsetX) / size)
    const row = Math.floor((y + offsetY) / size)
    const key = `${row}-${col}`
    if (key === this.lastPaintKey) {
      return
    }
    this.lastPaintKey = key
    this.store.applyToolAt(row, col)
  }

  getMinimapColor(type: NodeType): string {
    if (this.store.theme === 'light') {
      switch (type) {
        case NodeType.EMPTY:
          return this.store.params.backgroundColor || '#FFFFFF'
        case NodeType.START:
          return '#4CAF50'
        case NodeType.END:
          return '#F44336'
        case NodeType.OBSTACLE:
          return '#424242'
        case NodeType.PATH:
          return '#FFD600'
        case NodeType.EXPLORED:
          return '#90CAF9'
        default:
          return '#FFFFFF'
      }
    }
    switch (type) {
      case NodeType.EMPTY:
        return this.store.params.backgroundColor || '#1A1A1A'
      case NodeType.START:
        return '#66BB6A'
      case NodeType.END:
        return '#EF5350'
      case NodeType.OBSTACLE:
        return '#757575'
      case NodeType.PATH:
        return '#FFEE58'
      case NodeType.EXPLORED:
        return '#42A5F5'
      default:
        return '#1A1A1A'
    }
  }

  getMinimapViewRect(): MinimapViewRect {
    const size = this.getScaledCellSize()
    const contentW = this.store.mapData.cols * size + SCROLL_BAR_SIZE
    const contentH = this.store.mapData.rows * size + SCROLL_BAR_SIZE
    const vw = this.canvasWidth > 0 ? Math.max(1, this.canvasWidth - SCROLL_BAR_SIZE) : 1
    const vh = this.canvasHeight > 0 ? Math.max(1, this.canvasHeight - SCROLL_BAR_SIZE) : 1

    const w = Math.max(2, Math.min(MINIMAP_SIZE, Math.round(vw / contentW * MINIMAP_SIZE)))
    const h = Math.max(2, Math.min(MINIMAP_SIZE, Math.round(vh / contentH * MINIMAP_SIZE)))
    const x = Math.max(0, Math.min(MINIMAP_SIZE - w, Math.round(this.scrollX / contentW * MINIMAP_SIZE)))
    const y = Math.max(0, Math.min(MINIMAP_SIZE - h, Math.round(this.scrollY / contentH * MINIMAP_SIZE)))
    return { x: x, y: y, w: w, h: h }
  }

  getMinimapCellColorAt(r: number, c: number): string {
    const rr = Math.floor(r / MINIMAP_CELLS * this.store.mapData.rows)
    const cc = Math.floor(c / MINIMAP_CELLS * this.store.mapData.cols)
    return this.getMinimapColor(this.store.mapData.grid[rr][cc])
  }

  jumpToMinimapPoint(x: number, y: number): void {
    const size = this.getScaledCellSize()
    const contentW = this.store.mapData.cols * size + SCROLL_BAR_SIZE
    const contentH = this.store.mapData.rows * size + SCROLL_BAR_SIZE
    const vw = this.canvasWidth > 0 ? Math.max(1, this.canvasWidth - SCROLL_BAR_SIZE) : 1
    const vh = this.canvasHeight > 0 ? Math.max(1, this.canvasHeight - SCROLL_BAR_SIZE) : 1
    const maxX = Math.max(0, contentW - vw)
    const maxY = Math.max(0, contentH - vh)

    const targetX = Math.max(0, Math.min(maxX, x / MINIMAP_SIZE * contentW - vw / 2))
    const targetY = Math.max(0, Math.min(maxY, y / MINIMAP_SIZE * contentH - vh / 2))

    this.horizontalScroller.scrollTo({ xOffset: targetX, yOffset: 0, animation: false })
    this.verticalScroller.scrollTo({ xOffset: 0, yOffset: targetY, animation: false })
    this.scrollX = targetX
    this.scrollY = targetY
  }

  clampMinimapPosition(): void {
    const maxX = Math.max(0, this.canvasWidth - MINIMAP_SIZE - MINIMAP_MARGIN)
    const maxY = Math.max(0, this.canvasHeight - MINIMAP_SIZE - MINIMAP_MARGIN)
    const minX = this.canvasWidth > MINIMAP_SIZE + MINIMAP_MARGIN ? MINIMAP_MARGIN : 0
    const minY = this.canvasHeight > MINIMAP_SIZE + MINIMAP_MARGIN ? MINIMAP_MARGIN : 0
    this.minimapX = Math.max(minX, Math.min(maxX, this.minimapX))
    this.minimapY = Math.max(minY, Math.min(maxY, this.minimapY))
  }

  ensureMinimapPositionInitialized(): void {
    if (this.minimapInitialized) {
      this.clampMinimapPosition()
      return
    }
    if (this.canvasWidth <= 0 || this.canvasHeight <= 0) {
      return
    }
    this.minimapX = Math.max(0, this.canvasWidth - MINIMAP_SIZE - MINIMAP_MARGIN)
    this.minimapY = Math.max(0, MINIMAP_MARGIN)
    this.minimapInitialized = true
    this.clampMinimapPosition()
  }

  getCellColor(type: NodeType): ResourceColor {
    if (this.store.theme === 'light') {
      switch (type) {
        case NodeType.EMPTY:
          return this.store.params.backgroundColor || '#FFFFFF'
        case NodeType.START:
          return '#4CAF50'
        case NodeType.END:
          return '#F44336'
        case NodeType.OBSTACLE:
          return '#424242'
        case NodeType.PATH:
          return '#FFD600'
        case NodeType.EXPLORED:
          return '#90CAF9'
        default:
          return '#FFFFFF'
      }
    } else {
      switch (type) {
        case NodeType.EMPTY:
          return this.store.params.backgroundColor || '#1A1A1A'
        case NodeType.START:
          return '#66BB6A'
        case NodeType.END:
          return '#EF5350'
        case NodeType.OBSTACLE:
          return '#757575'
        case NodeType.PATH:
          return '#FFEE58'
        case NodeType.EXPLORED:
          return '#42A5F5'
        default:
          return '#1A1A1A'
      }
    }
  }

  build() {
    Column() {
      Stack() {
        Scroll(this.horizontalScroller) {
          Scroll(this.verticalScroller) {
            Column({ space: 0 }) {
              ForEach(this.store.mapData.grid, (row: NodeType[], rowIndex: number) => {
                Row({ space: 0 }) {
                  ForEach(row, (cell: NodeType, colIndex: number) => {
                    if (this.algorithm === null && this.store.currentTool === ToolType.SELECT) {
                      if (this.isCellSelected(rowIndex, colIndex)) {
                        Stack() {
                          Column()
                            .width('100%')
                            .height('100%')
                            .backgroundColor(this.getCellColor(this.getDisplayNodeType(rowIndex, colIndex, cell)))
                          this.ComparePathOverlay(rowIndex, colIndex, cell)
                          this.VisualizationOverlay(rowIndex, colIndex, cell)
                          Column()
                            .width('100%')
                            .height('100%')
                            .border({ width: 2, color: this.store.getColor('navix_accent_highlight') })
                            .backgroundColor(Color.Transparent)
                        }
                          .width(this.getScaledCellSize())
                          .height(this.getScaledCellSize())
                          .border({
                            width: this.store.params.showGridLines ? 1 : 0,
                            color: this.store.params.gridLineColor || this.store.getColor('navix_grid_line')
                          })
                          .onClick(() => {
                            this.store.selectCell(rowIndex, colIndex)
                            this.store.openSelectedCellMenu()
                          })
                          .bindMenu(this.store.selectedCellMenuOpen && this.isCellSelected(rowIndex, colIndex), [
                            {
                              value: '设为障碍',
                              action: () => {
                                this.store.setCellAsObstacle(rowIndex, colIndex)
                              }
                            },
                            {
                              value: '设为起点',
                              action: () => {
                                this.store.setCellAsStart(rowIndex, colIndex)
                              }
                            },
                            {
                              value: '设为终点',
                              action: () => {
                                this.store.setCellAsEnd(rowIndex, colIndex)
                              }
                            }
                          ], {
                            onDisappear: () => {
                              this.store.closeSelectedCellMenu()
                            }
                          })
                      } else {
                        Stack() {
                          Column()
                            .width('100%')
                            .height('100%')
                            .backgroundColor(this.getCellColor(this.getDisplayNodeType(rowIndex, colIndex, cell)))
                          this.ComparePathOverlay(rowIndex, colIndex, cell)
                          this.VisualizationOverlay(rowIndex, colIndex, cell)
                        }
                          .width(this.getScaledCellSize())
                          .height(this.getScaledCellSize())
                          .border({
                            width: this.store.params.showGridLines ? 1 : 0,
                            color: this.store.params.gridLineColor || this.store.getColor('navix_grid_line')
                          })
                          .onClick(() => {
                            this.store.selectCell(rowIndex, colIndex)
                          })
                      }
                    } else {
                      Stack() {
                        Column()
                          .width('100%')
                          .height('100%')
                          .backgroundColor(this.getCellColor(this.getDisplayNodeType(rowIndex, colIndex, cell)))
                        this.ComparePathOverlay(rowIndex, colIndex, cell)
                        this.VisualizationOverlay(rowIndex, colIndex, cell)
                      }
                        .width(this.getScaledCellSize())
                        .height(this.getScaledCellSize())
                        .border({
                          width: this.store.params.showGridLines ? 1 : 0,
                          color: this.store.params.gridLineColor || this.store.getColor('navix_grid_line')
                        })
                        .onClick(() => {
                          if (this.algorithm !== null) {
                            return
                          }
                          if (this.store.currentTool === ToolType.RANDOM) {
                            return
                          }
                          this.store.applyToolAt(rowIndex, colIndex)
                        })
                    }
                  }, (_cell: NodeType, colIndex: number) => `${this.store.mapVersion}-${rowIndex}-${colIndex}`)
                }
              }, (_row: NodeType[], rowIndex: number) => `${this.store.mapVersion}-${rowIndex}`)
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ right: 10, bottom: 10 })
            .onTouch((event: TouchEvent) => {
              if (!this.canEditGrid()) {
                return
              }
              const t = event.touches?.[0]
              if (!t) {
                return
              }
              if (event.type === TouchType.Down) {
                this.painting = true
                this.lastPaintKey = ''
                this.applyAtPoint(t.x, t.y)
                return
              }
              if (event.type === TouchType.Move) {
                if (this.painting) {
                  this.applyAtPoint(t.x, t.y)
                }
                return
              }
              if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.painting = false
                this.lastPaintKey = ''
              }
            })
          }
          .scrollable(this.painting ? ScrollDirection.None : ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
          .onDidScroll(() => {
            this.scrollY = this.verticalScroller.currentOffset().yOffset
          })
        }
        .scrollable(this.painting ? ScrollDirection.None : ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .onDidScroll(() => {
          this.scrollX = this.horizontalScroller.currentOffset().xOffset
        })

        ScrollBar({ scroller: this.verticalScroller, direction: ScrollBarDirection.Vertical, state: BarState.On })
          .width(10)
          .height('100%')
          .position({ right: 0 })

        ScrollBar({ scroller: this.horizontalScroller, direction: ScrollBarDirection.Horizontal, state: BarState.On })
          .width('100%')
          .height(10)
          .position({ bottom: 0 })

        this.LegendOverlay()

        if (this.algorithm === null) {
          Stack() {
            Column({ space: 0 }) {
              ForEach(MINIMAP_INDICES, (r: number) => {
                Row({ space: 0 }) {
                  ForEach(MINIMAP_INDICES, (c: number) => {
                    Column()
                      .width(MINIMAP_SIZE / MINIMAP_CELLS)
                      .height(MINIMAP_SIZE / MINIMAP_CELLS)
                      .backgroundColor(this.getMinimapCellColorAt(r, c))
                  }, (_: number, idx: number) => `${this.store.mapVersion}-${r}-${idx}`)
                }
              }, (item: number) => `${this.store.mapVersion}-${item}`)
            }

            Column()
              .width(this.getMinimapViewRect().w)
              .height(this.getMinimapViewRect().h)
              .position({ x: this.getMinimapViewRect().x, y: this.getMinimapViewRect().y })
              .border({ width: 1, color: this.store.getColor('navix_accent_highlight') })
              .backgroundColor(Color.Transparent)
          }
          .width(MINIMAP_SIZE)
          .height(MINIMAP_SIZE)
          .borderRadius(6)
          .border({ width: 1, color: this.store.getColor('navix_border_color') })
          .backgroundColor(this.store.getColor('navix_bg_canvas'))
          .shadow({ radius: 12, color: '#33000000', offsetX: 0, offsetY: 4 })
          .clip(true)
          .position({ x: this.minimapX, y: this.minimapY })
          .gesture(
            GestureGroup(GestureMode.Exclusive,
              PanGesture({ direction: PanDirection.All, distance: 1 })
                .onActionStart((_event?: GestureEvent) => {
                  this.minimapDragging = true
                  this.minimapDragStartX = this.minimapX
                  this.minimapDragStartY = this.minimapY
                })
                .onActionUpdate((event?: GestureEvent) => {
                  if (!event) {
                    return
                  }
                  this.minimapX = this.minimapDragStartX + event.offsetX
                  this.minimapY = this.minimapDragStartY + event.offsetY
                  this.clampMinimapPosition()
                })
                .onActionEnd((_event?: GestureEvent) => {
                  this.minimapDragging = false
                }),
              TapGesture({ count: 1, fingers: 1 })
                .onAction((event?: GestureEvent) => {
                  if (!event || !event.tapLocation) {
                    return
                  }
                  if (this.minimapDragging) {
                    return
                  }
                  this.jumpToMinimapPoint(event.tapLocation.x, event.tapLocation.y)
                })
            )
          )
        }
      }
      .width('100%')
      .height('100%')
      .onAreaChange((_oldValue: Area, newValue: Area) => {
        const w = typeof newValue.width === 'number' ? newValue.width : Number.parseFloat(newValue.width as string)
        const h = typeof newValue.height === 'number' ? newValue.height : Number.parseFloat(newValue.height as string)
        this.canvasWidth = Number.isFinite(w) ? w : 0
        this.canvasHeight = Number.isFinite(h) ? h : 0
        this.ensureMinimapPositionInitialized()
      })
    }
    .layoutWeight(1)
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
