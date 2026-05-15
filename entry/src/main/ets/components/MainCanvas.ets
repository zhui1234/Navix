import { NavixStore, navixStore } from '../store/NavixStore'
import { NodeType, ToolType, MapType } from '../models/MapTypes'

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
                    Column()
                      .width(this.getScaledCellSize())
                      .height(this.getScaledCellSize())
                      .backgroundColor(this.getCellColor(cell))
                      .border({
                        width: this.store.params.showGridLines ? 1 : 0,
                        color: this.store.params.gridLineColor || this.store.getColor('navix_grid_line')
                      })
                      .onClick(() => {
                        this.store.applyToolAt(rowIndex, colIndex)
                      })
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
