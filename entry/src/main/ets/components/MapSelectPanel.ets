import { NavixStore, navixStore } from '../store/NavixStore'
import { RightPanelState } from '../models/MapTypes'

@ComponentV2
export struct MapSelectPanel {
  @Local store: NavixStore = navixStore
  @Local hoveredOption: string | null = null
  @Local selectedMap: string = 'empty'

  build() {
    Column({ space: 8 }) {
      Row() {
        Text('地图选择')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.navix_text_primary'))

        Blank()

        SymbolGlyph($r('sys.symbol.minus'))
          .fontSize(14)
          .fontColor([$r('app.color.navix_icon_color')])
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
        .color($r('app.color.navix_border_color'))
        .margin({ left: 8, right: 8, top: 4, bottom: 4 })

      Row() {
        Text('加载地图')
          .fontSize(13)
          .fontColor($r('app.color.navix_text_primary'))
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .borderRadius(6)
      .backgroundColor(this.hoveredOption === 'load' ? '#EEEEEE' : Color.Transparent)
      .onHover((isHover: boolean) => {
        this.hoveredOption = isHover ? 'load' : null
      })

      Row() {
        Text('保存地图')
          .fontSize(13)
          .fontColor($r('app.color.navix_text_primary'))
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .borderRadius(6)
      .backgroundColor(this.hoveredOption === 'save' ? '#EEEEEE' : Color.Transparent)
      .onHover((isHover: boolean) => {
        this.hoveredOption = isHover ? 'save' : null
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 6, right: 6, bottom: 10 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  OptionButton(id: string, label: string, hint: string) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(13)
        .fontColor(this.selectedMap === id ? '#333333' : $r('app.color.navix_text_primary'))
        .fontWeight(this.selectedMap === id ? FontWeight.Medium : FontWeight.Normal)

      if (this.hoveredOption === id) {
        Text(hint)
          .fontSize(11)
          .fontColor($r('app.color.navix_text_secondary'))
          .lineHeight(14)
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .borderRadius(6)
    .backgroundColor(this.selectedMap === id ? '#DDDDDD' : (this.hoveredOption === id ? '#EEEEEE' : Color.Transparent))
    .onHover((isHover: boolean) => {
      this.hoveredOption = isHover ? id : null
    })
    .onClick(() => {
      this.selectedMap = id
    })
  }
}
