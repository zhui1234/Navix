@ComponentV2
export struct MainCanvas {
  build() {
    Column() {
      Text('画布区域')
        .fontSize(16)
        .fontColor($r('app.color.navix_text_secondary'))
    }
    .layoutWeight(1)
    .height('100%')
    .backgroundColor($r('app.color.navix_bg_canvas'))
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
