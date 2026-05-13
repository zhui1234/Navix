import { TitleBar } from '../components/TitleBar'

@Entry
@Component
struct Index {
  build() {
    Column() {
      TitleBar()

      Column() {
        Row() {
          Column() {
            Text('🔧')
              .fontSize(20)
              .textAlign(TextAlign.Center)
            Text('🧮')
              .fontSize(20)
              .textAlign(TextAlign.Center)
          }
          .width(48)
          .height('100%')
          .backgroundColor($r('app.color.navix_bg_panel'))
          .alignItems(HorizontalAlign.Center)
          .padding({ top: 16 })
          .justifyContent(FlexAlign.Start)

          Column() {
            Text('')
              .fontSize(20)
              .textAlign(TextAlign.Center)
          }
          .width(0)
          .height('100%')
          .backgroundColor($r('app.color.navix_bg_panel'))

          Column() {
            Text('画布区域')
              .fontSize(20)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .height('100%')
          .layoutWeight(1)
          .backgroundColor($r('app.color.navix_bg_canvas'))
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('')
              .fontSize(20)
              .textAlign(TextAlign.Center)
          }
          .width(0)
          .height('100%')
          .backgroundColor($r('app.color.navix_bg_panel'))

          Column() {
            Text('🗺')
              .fontSize(20)
              .textAlign(TextAlign.Center)
            Text('⚙')
              .fontSize(20)
              .textAlign(TextAlign.Center)
            Text('📊')
              .fontSize(20)
              .textAlign(TextAlign.Center)
          }
          .width(48)
          .height('100%')
          .backgroundColor($r('app.color.navix_bg_panel'))
          .alignItems(HorizontalAlign.Center)
          .padding({ top: 16 })
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height(0)
      .layoutWeight(1)

      Column() {
        Row() {
          Text('● 就绪')
            .fontSize(12)
            .fontColor('#4CAF50')
          Text(' | ')
            .fontSize(12)
            .fontColor($r('app.color.navix_text_secondary'))
          Text('地图大小: 20×20')
            .fontSize(12)
            .fontColor($r('app.color.navix_text_secondary'))
          Text(' | ')
            .fontSize(12)
            .fontColor($r('app.color.navix_text_secondary'))
          Text('搜索节点: 0')
            .fontSize(12)
            .fontColor($r('app.color.navix_text_secondary'))
          Text(' | ')
            .fontSize(12)
            .fontColor($r('app.color.navix_text_secondary'))
          Text('路径长度: 0')
            .fontSize(12)
            .fontColor($r('app.color.navix_text_secondary'))
          Text(' | ')
            .fontSize(12)
            .fontColor($r('app.color.navix_text_secondary'))
          Text('时间: 0ms')
            .fontSize(12)
            .fontColor($r('app.color.navix_text_secondary'))
        }
        .width('100%')
        .height('100%')
        .padding({ left: 12, right: 12 })
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height(36)
      .backgroundColor($r('app.color.navix_bg_statusbar'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.navix_bg_primary'))
  }
}
