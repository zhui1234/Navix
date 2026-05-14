import { NavixStore, navixStore } from '../store/NavixStore'
import { RightPanelState } from '../models/MapTypes'

@ComponentV2
export struct ParamsPanel {
  @Local store: NavixStore = navixStore
  @Local hoveredSection: string | null = null

  build() {
    Column({ space: 6 }) {
      Row() {
        Text('参数设置')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.navix_text_primary'))

        Blank()

        SymbolGlyph($r('sys.symbol.minus'))
          .fontSize(14)
          .fontColor([$r('app.color.navix_icon_color')])
          .onClick(() => {
            this.store.toggleRightPanel(RightPanelState.PARAMS)
          })
      }
      .width('100%')
      .padding({ top: 10, left: 8, right: 8 })

      this.SectionHeader('网格设置', 'grid')

      if (this.hoveredSection === 'grid') {
        Column({ space: 4 }) {
          Row() {
            Text('行数')
              .fontSize(12)
              .fontColor($r('app.color.navix_text_secondary'))
            Blank()
            Text('20')
              .fontSize(12)
              .fontColor($r('app.color.navix_text_primary'))
          }
          .width('100%')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })

          Row() {
            Text('列数')
              .fontSize(12)
              .fontColor($r('app.color.navix_text_secondary'))
            Blank()
            Text('20')
              .fontSize(12)
              .fontColor($r('app.color.navix_text_primary'))
          }
          .width('100%')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })

          Row() {
            Text('显示网格线')
              .fontSize(12)
              .fontColor($r('app.color.navix_text_secondary'))
            Blank()
            Text('开')
              .fontSize(12)
              .fontColor($r('app.color.navix_text_primary'))
          }
          .width('100%')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        }
        .padding({ top: 4, bottom: 4 })
      }

      Divider()
        .color($r('app.color.navix_border_color'))
        .margin({ left: 8, right: 8, top: 2, bottom: 2 })

      this.SectionHeader('算法设置', 'algorithm')

      if (this.hoveredSection === 'algorithm') {
        Column({ space: 4 }) {
          Row() {
            Text('启发式类型')
              .fontSize(12)
              .fontColor($r('app.color.navix_text_secondary'))
            Blank()
            Text('曼哈顿')
              .fontSize(12)
              .fontColor($r('app.color.navix_text_primary'))
          }
          .width('100%')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })

          Row() {
            Text('权重')
              .fontSize(12)
              .fontColor($r('app.color.navix_text_secondary'))
            Blank()
            Text('1.0')
              .fontSize(12)
              .fontColor($r('app.color.navix_text_primary'))
          }
          .width('100%')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })

          Row() {
            Text('允许对角移动')
              .fontSize(12)
              .fontColor($r('app.color.navix_text_secondary'))
            Blank()
            Text('关')
              .fontSize(12)
              .fontColor($r('app.color.navix_text_primary'))
          }
          .width('100%')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        }
        .padding({ top: 4, bottom: 4 })
      }

      Divider()
        .color($r('app.color.navix_border_color'))
        .margin({ left: 8, right: 8, top: 2, bottom: 2 })

      this.SectionHeader('动画设置', 'animation')

      if (this.hoveredSection === 'animation') {
        Column({ space: 4 }) {
          Row() {
            Text('动画速度')
              .fontSize(12)
              .fontColor($r('app.color.navix_text_secondary'))
            Blank()
            Text('50ms')
              .fontSize(12)
              .fontColor($r('app.color.navix_text_primary'))
          }
          .width('100%')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        }
        .padding({ top: 4, bottom: 4 })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 6, right: 6, bottom: 10 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  SectionHeader(title: string, id: string) {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_down'))
        .fontSize(12)
        .fontColor([$r('app.color.navix_text_secondary')])
        .width(16)

      Text(title)
        .fontSize(12)
        .fontColor($r('app.color.navix_text_primary'))
    }
    .width('100%')
    .padding({ left: 4, top: 6, bottom: 6 })
    .borderRadius(4)
    .backgroundColor(this.hoveredSection === id ? '#EEEEEE' : Color.Transparent)
    .onHover((isHover: boolean) => {
      this.hoveredSection = isHover ? id : null
    })
  }
}
