@Component
export struct TitleBar {
  build() {
    Row() {
      Row({ space: 8 }) {
        Text('⊿')
          .fontSize(20)
          .fontColor($r('app.color.navix_text_primary'))
        Text('☰')
          .fontSize(18)
          .fontColor($r('app.color.navix_text_primary'))
        Text('?')
          .fontSize(16)
          .fontColor($r('app.color.navix_text_primary'))
      }
      Blank()
      Row({ space: 6 }) {
        Text('⏮')
          .fontSize(14)
          .fontColor($r('app.color.navix_text_secondary'))
        Text('◀')
          .fontSize(14)
          .fontColor($r('app.color.navix_text_secondary'))
        Text('步骤 0/0')
          .fontSize(12)
          .fontColor($r('app.color.navix_text_secondary'))
        Text('▶')
          .fontSize(14)
          .fontColor($r('app.color.navix_text_secondary'))
        Text('▶▶')
          .fontSize(14)
          .fontColor($r('app.color.navix_text_secondary'))
        Text('⏭')
          .fontSize(14)
          .fontColor($r('app.color.navix_text_secondary'))
      }
      Blank()
      Row({ space: 10 }) {
        Text('⚙')
          .fontSize(16)
          .fontColor($r('app.color.navix_text_primary'))
        Text('─')
          .fontSize(16)
          .fontColor($r('app.color.navix_text_primary'))
        Text('◻')
          .fontSize(16)
          .fontColor($r('app.color.navix_text_primary'))
        Text('✕')
          .fontSize(16)
          .fontColor($r('app.color.navix_text_primary'))
      }
    }
    .width('100%')
    .height(48)
    .backgroundColor($r('app.color.navix_bg_titlebar'))
    .padding({ left: 8, right: 8 })
    .alignItems(VerticalAlign.Center)
  }
}