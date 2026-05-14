import { NavixStore, navixStore } from '../store/NavixStore'
import { RightPanelState } from '../models/MapTypes'

@ComponentV2
export struct MapSettingsPanel {
  @Local store: NavixStore = navixStore

  build() {
    Column({ space: 8 }) {
      Row() {
        Text('地图设置')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.store.getColor('navix_text_primary'))

        Blank()

        SymbolGlyph($r('sys.symbol.minus'))
          .fontSize(14)
          .fontColor([this.store.getColor('navix_icon_color')])
          .onClick(() => {
            this.store.toggleRightPanel(RightPanelState.MAP_SETTINGS)
          })
      }
      .width('100%')
      .padding({ top: 10, left: 8, right: 8 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 6, right: 6, bottom: 10 })
    .alignItems(HorizontalAlign.Start)
  }
}
