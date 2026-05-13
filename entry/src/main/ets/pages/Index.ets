import { TitleBar } from '../components/TitleBar'
import { StatusBar } from '../components/StatusBar'
import { LeftTriggerBar } from '../components/LeftTriggerBar'

@Entry
@Component
struct Index {
  build() {
    Column() {
      TitleBar()

      Column() {
        Row() {
          LeftTriggerBar()

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

      StatusBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.navix_bg_primary'))
  }
}
