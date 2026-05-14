import { NavixStore } from '../store/NavixStore'
import { navixStore } from '../store/NavixStore'
import { LeftPanelState } from '../models/MapTypes'

@ComponentV2
export struct LeftTriggerBar {
  @Local store: NavixStore = navixStore

  build() {
    Column({space: 16}) {
      SymbolGlyph($r('sys.symbol.briefcase'))
        .fontSize(24)
        .fontColor([$r('app.color.navix_icon_color')])
        .onClick(() => {
          this.store.toggleLeftPanel(LeftPanelState.TOOLS)
        })
      SymbolGlyph($r('sys.symbol.puzzle'))
        .fontSize(24)
        .fontColor([$r('app.color.navix_icon_color')])
        .onClick(() => {
          this.store.toggleLeftPanel(LeftPanelState.ALGORITHMS)
        })
    }
    .width(48)
    .height('100%')
    .backgroundColor($r('app.color.navix_bg_toolbar'))
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({ top: 16 })
  }
}
