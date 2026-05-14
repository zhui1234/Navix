import { NavixStore, navixStore } from '../store/NavixStore'
import { NodeType } from '../models/MapTypes'

@ComponentV2
export struct MainCanvas {
  @Local store: NavixStore = navixStore

  getCellColor(type: NodeType): ResourceColor {
    if (this.store.theme === 'light') {
      switch (type) {
        case NodeType.EMPTY:
          return '#FFFFFF'
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
          return '#1A1A1A'
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
        Column({ space: 0 }) {
          ForEach(this.store.mapData.grid, (row: NodeType[], rowIndex: number) => {
            Row({ space: 0 }) {
              ForEach(row, (cell: NodeType, colIndex: number) => {
                Column()
                  .width(this.store.params.cellSize)
                  .height(this.store.params.cellSize)
                  .backgroundColor(this.getCellColor(cell))
              }, (_cell: NodeType, colIndex: number) => `${rowIndex}-${colIndex}`)
            }
          }, (_row: NodeType[], rowIndex: number) => `${rowIndex}`)
        }
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Center)
    }
    .layoutWeight(1)
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
