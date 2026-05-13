@Component
export struct LeftTriggerBar {
  build() {
    Column({space: 16}) {
      Text('🔧')
        .fontSize(20)
        .fontColor($r('app.color.navix_text_primary'))
      Text('🧮')
        .fontSize(20)
        .fontColor($r('app.color.navix_text_primary'))
    }
    .width(48)
    .height('100%')
    .backgroundColor($r('app.color.navix_bg_panel'))
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({ top: 16 })
  }
}
