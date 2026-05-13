@Component
export struct RightPanel {
  build() {
    Column() {
      Text('工具/算法面板')
        .fontSize(14)
        .fontColor($r('app.color.navix_text_secondary'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.navix_bg_panel'))
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding({ left: 12 })
  }
}
