import { NavixStore, navixStore } from '../store/NavixStore'
import { NodeType, ToolType, MapType } from '../models/MapTypes'

@ComponentV2
export struct MainCanvas {
  @Local store: NavixStore = navixStore
  private horizontalScroller: Scroller = new Scroller()
  private verticalScroller: Scroller = new Scroller()
  @Local private painting: boolean = false
  @Local private lastPaintKey: string = ''

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
        }
        .scrollable(this.painting ? ScrollDirection.None : ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)

        ScrollBar({ scroller: this.verticalScroller, direction: ScrollBarDirection.Vertical, state: BarState.On })
          .width(10)
          .height('100%')
          .position({ right: 0 })

        ScrollBar({ scroller: this.horizontalScroller, direction: ScrollBarDirection.Horizontal, state: BarState.On })
          .width('100%')
          .height(10)
          .position({ bottom: 0 })
      }
      .width('100%')
      .height('100%')
    }
    .layoutWeight(1)
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
