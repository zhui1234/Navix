import { NavixStore } from '../store/NavixStore'
import { navixStore } from '../store/NavixStore'
import { RightPanelState } from '../models/MapTypes'

@ComponentV2
export struct RightTriggerBar {
  @Local store: NavixStore = navixStore

  build() {
    Column({space: 16}) {
      SymbolGlyph($r('sys.symbol.map'))
        .fontSize(24)
        .fontColor([this.store.getColor('navix_icon_color')])
        .onClick(() => {
          this.store.toggleRightPanel(this.store.rightPanelState === RightPanelState.MAP_SELECT ? RightPanelState.COLLAPSED : RightPanelState.MAP_SELECT)
        })
      SymbolGlyph($r('sys.symbol.slider_horizontal_2'))
        .fontSize(24)
        .fontColor([this.store.getColor('navix_icon_color')])
        .onClick(() => {
          this.store.toggleRightPanel(this.store.rightPanelState === RightPanelState.PARAMS ? RightPanelState.COLLAPSED : RightPanelState.PARAMS)
        })
      SymbolGlyph($r('sys.symbol.more'))
        .fontSize(24)
        .fontColor([this.store.getColor('navix_icon_color')])
        .onClick(() => {
          this.store.toggleRightPanel(this.store.rightPanelState === RightPanelState.HEATMAP ? RightPanelState.COLLAPSED : RightPanelState.HEATMAP)
        })
    }
    .width(48)
    .height('100%')
    .backgroundColor(this.store.getColor('navix_bg_toolbar'))
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({ top: 16 })
  }
}