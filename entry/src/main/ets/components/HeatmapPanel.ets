import { NavixStore, navixStore } from '../store/NavixStore'
import { RightPanelState } from '../models/MapTypes'

@ComponentV2
export struct HeatmapPanel {
  @Local store: NavixStore = navixStore
  @Local hoveredType: string | null = null
  @Local selectedType: string = 'search'

  build() {
    Column({ space: 8 }) {
      Row() {
        Text('热力图配置')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.store.getColor('navix_text_primary'))

        Blank()

        SymbolGlyph($r('sys.symbol.minus'))
          .fontSize(14)
          .fontColor([this.store.getColor('navix_icon_color')])
          .onClick(() => {
            this.store.toggleRightPanel(RightPanelState.HEATMAP)
          })
      }
      .width('100%')
      .padding({ top: 10, left: 8, right: 8 })

      Text('热力图类型')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_secondary'))
        .width('100%')
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })

      this.TypeButton('search', '搜索热力图', '显示探索节点的密度分布')
      this.TypeButton('path', '路径热力图', '显示最短路径的覆盖区域')
      this.TypeButton('obstacle', '障碍热力图', '显示障碍物的分布密度')
      this.TypeButton('custom', '自定义', '根据自定义数据生成热力图')

      Divider()
        .color(this.store.getColor('navix_border_color'))
        .margin({ left: 8, right: 8, top: 4, bottom: 4 })

      Text('渐变色方案')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_secondary'))
        .width('100%')
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })

      Row() {
        Text('蓝-绿-红')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_primary'))
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .borderRadius(6)
      .backgroundColor(Color.Transparent)

      Divider()
        .color(this.store.getColor('navix_border_color'))
        .margin({ left: 8, right: 8, top: 4, bottom: 4 })

      Text('透明度')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_secondary'))
        .width('100%')
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })

      Row() {
        Text('50%')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_primary'))
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .borderRadius(6)
      .backgroundColor(Color.Transparent)

      Row() {
        SymbolGlyph($r('sys.symbol.checkmark_square'))
          .fontSize(14)
          .fontColor([this.store.getColor('navix_icon_color')])

        Text('实时更新')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_primary'))
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .borderRadius(6)
      .backgroundColor(Color.Transparent)

      Row() {
        SymbolGlyph($r('sys.symbol.checkmark_square'))
          .fontSize(14)
          .fontColor([this.store.getColor('navix_icon_color')])

        Text('显示图例')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_primary'))
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .borderRadius(6)
      .backgroundColor(Color.Transparent)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 6, right: 6, bottom: 10 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TypeButton(id: string, name: string, hint: string) {
    Column({ space: 2 }) {
      Text(name)
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_primary'))
        .fontWeight(this.selectedType === id ? FontWeight.Medium : FontWeight.Normal)

      if (this.hoveredType === id) {
        Text(hint)
          .fontSize(10)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .lineHeight(13)
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 7, bottom: 7 })
    .borderRadius(6)
    .backgroundColor(this.selectedType === id ? this.store.getColor('navix_button_active') : (this.hoveredType === id ? this.store.getColor('navix_border_color') : Color.Transparent))
    .onHover((isHover: boolean) => {
      this.hoveredType = isHover ? id : null
    })
    .onClick(() => {
      this.selectedType = id
    })
  }
}
