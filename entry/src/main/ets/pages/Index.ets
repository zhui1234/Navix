@Entry
@Component
struct Index {
  build() {
    Column() {
      Column() {
        Text('TitleBar')
          .fontSize(16)
      }
      .width('100%')
      .height(48)
      .backgroundColor($r('app.color.navix_bg_titlebar'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Row() {
        Column() {
          Text('LeftTrigger')
            .fontSize(14)
        }
        .width(48)
        .height('100%')
        .backgroundColor($r('app.color.navix_bg_panel'))
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('LeftPanel')
            .fontSize(14)
        }
        .width(0)
        .height('100%')
        .backgroundColor($r('app.color.navix_bg_panel'))
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('Canvas')
            .fontSize(14)
        }
        .layoutWeight(1)
        .height('100%')
        .backgroundColor($r('app.color.navix_bg_canvas'))
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('RightPanel')
            .fontSize(14)
        }
        .width(0)
        .height('100%')
        .backgroundColor($r('app.color.navix_bg_panel'))
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('RightTrigger')
            .fontSize(14)
        }
        .width(48)
        .height('100%')
        .backgroundColor($r('app.color.navix_bg_panel'))
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)

      Column() {
        Text('StatusBar')
          .fontSize(14)
      }
      .width('100%')
      .height(36)
      .backgroundColor($r('app.color.navix_bg_statusbar'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}