import { NavixStore, navixStore } from '../store/NavixStore'
import { NodeType } from '../models/MapTypes'

@ComponentV2
export struct MainCanvas {
  @Local store: NavixStore = navixStore
  private horizontalScroller: Scroller = new Scroller()
  private verticalScroller: Scroller = new Scroller()

  getScaledCellSize(): number {
    return Math.round(this.store.params.cellSize * this.store.canvasZoomPercent / 100)
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
                  ForEach(row, (cell: NodeType) => {
                    Column()
                      .width(this.getScaledCellSize())
                      .height(this.getScaledCellSize())
                      .backgroundColor(this.getCellColor(cell))
                      .border({
                        width: this.store.params.showGridLines ? 1 : 0,
                        color: this.store.params.gridLineColor || this.store.getColor('navix_grid_line')
                      })
                  }, (_cell: NodeType, colIndex: number) => `${this.store.mapVersion}-${rowIndex}-${colIndex}`)
                }
              }, (_row: NodeType[], rowIndex: number) => `${this.store.mapVersion}-${rowIndex}`)
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ right: 10, bottom: 10 })
          }
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
        }
        .scrollable(ScrollDirection.Horizontal)
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
