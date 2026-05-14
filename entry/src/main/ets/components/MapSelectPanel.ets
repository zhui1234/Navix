import { NavixStore, navixStore } from '../store/NavixStore'
import { RightPanelState } from '../models/MapTypes'

@ComponentV2
export struct MapSelectPanel {
  @Local store: NavixStore = navixStore
  @Local hoveredOption: string | null = null
  @Local selectedMap: string = 'empty'
  
  @Computed
  get mapRows(): number {
    return this.store.params.gridRows
  }
  
  @Computed
  get mapCols(): number {
    return this.store.params.gridCols
  }

  build() {
    Column({ space: 8 }) {
      Row() {
        Text('地图选择')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.store.getColor('navix_text_primary'))

        Blank()

        SymbolGlyph($r('sys.symbol.minus'))
          .fontSize(14)
          .fontColor([this.store.getColor('navix_icon_color')])
          .onClick(() => {
            this.store.toggleRightPanel(RightPanelState.MAP_SELECT)
          })
      }
      .width('100%')
      .padding({ top: 10, left: 8, right: 8 })

      this.OptionButton('empty', '空地图', '清空所有内容，创建空白网格')
      this.OptionButton('maze', '迷宫', '预定义的迷宫地图')
      this.OptionButton('rooms', '房间', '多个房间和通道的地图')
      this.OptionButton('symmetric', '对称', '具有对称结构的地图')
      this.OptionButton('random', '随机', '随机生成障碍物分布')

      Divider()
        .color(this.store.getColor('navix_border_color'))
        .margin({ left: 8, right: 8, top: 4, bottom: 4 })

      Column({ space: 6 }) {
        Text('地图尺寸')
          .fontSize(13)
          .fontColor(this.store.getColor('navix_text_primary'))
          .width('100%')

        Row({ space: 8 }) {
          Column({ space: 2 }) {
            Text('行数')
              .fontSize(11)
              .fontColor(this.store.getColor('navix_text_secondary'))
            TextInput({ text: this.mapRows.toString() })
              .type(InputType.Number)
              .fontSize(12)
              .onChange((value: string) => {
                const num = parseInt(value)
                if (!isNaN(num) && num >= 1 && num <= 100) {
                  this.store.updateParams({ gridRows: num })
                } else if (!isNaN(num) && num < 1) {
                  this.store.updateParams({ gridRows: 1 })
                }
              })
          }
          .layoutWeight(1)

          Column({ space: 2 }) {
            Text('列数')
              .fontSize(11)
              .fontColor(this.store.getColor('navix_text_secondary'))
            TextInput({ text: this.mapCols.toString() })
              .type(InputType.Number)
              .fontSize(12)
              .onChange((value: string) => {
                const num = parseInt(value)
                if (!isNaN(num) && num >= 1 && num <= 100) {
                  this.store.updateParams({ gridCols: num })
                } else if (!isNaN(num) && num < 1) {
                  this.store.updateParams({ gridCols: 1 })
                }
              })
          }
          .layoutWeight(1)
        }
        .width('100%')

        Button('应用')
          .width('100%')
          .fontSize(12)
          .height(32)
          .onClick(() => {
            this.applyMap()
          })
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })

      Divider()
        .color(this.store.getColor('navix_border_color'))
        .margin({ left: 8, right: 8, top: 4, bottom: 4 })

      Row() {
        Text('加载地图')
          .fontSize(13)
          .fontColor(this.store.getColor('navix_text_primary'))
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .borderRadius(6)
      .backgroundColor(this.hoveredOption === 'load' ? this.store.getColor('navix_border_color') : Color.Transparent)
      .onHover((isHover: boolean) => {
        this.hoveredOption = isHover ? 'load' : null
      })

      Row() {
        Text('保存地图')
          .fontSize(13)
          .fontColor(this.store.getColor('navix_text_primary'))
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .borderRadius(6)
      .backgroundColor(this.hoveredOption === 'save' ? this.store.getColor('navix_border_color') : Color.Transparent)
      .onHover((isHover: boolean) => {
        this.hoveredOption = isHover ? 'save' : null
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 6, right: 6, bottom: 10 })
    .alignItems(HorizontalAlign.Start)
  }

  applyMap() {
    switch (this.selectedMap) {
      case 'empty':
        this.store.generateEmptyMap(this.mapRows, this.mapCols)
        break
      case 'maze':
        this.store.generateMazeMap(this.mapRows, this.mapCols)
        break
      case 'rooms':
        this.store.generateRoomsMap(this.mapRows, this.mapCols)
        break
      case 'symmetric':
        this.store.generateSymmetricMap(this.mapRows, this.mapCols)
        break
      case 'random':
        this.store.generateRandomMap(this.mapRows, this.mapCols)
        break
    }
  }

  @Builder
  OptionButton(id: string, label: string, hint: string) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(13)
        .fontColor(this.store.getColor('navix_text_primary'))
        .fontWeight(this.selectedMap === id ? FontWeight.Medium : FontWeight.Normal)

      if (this.hoveredOption === id) {
        Text(hint)
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .lineHeight(14)
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .borderRadius(6)
    .backgroundColor(this.selectedMap === id ? this.store.getColor('navix_button_active') : (this.hoveredOption === id ? this.store.getColor('navix_border_color') : Color.Transparent))
    .onHover((isHover: boolean) => {
      this.hoveredOption = isHover ? id : null
    })
    .onClick(() => {
      this.selectedMap = id
    })
  }
}
