@ComponentV2
export struct StatusBar {
  build() {
    Row() {
      Row({ space: 4 }) {
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
    }
    .width('100%')
    .height(36)
    .backgroundColor($r('app.color.navix_bg_toolbar'))
    .padding({ left: 12, right: 12 })
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
  }
}
