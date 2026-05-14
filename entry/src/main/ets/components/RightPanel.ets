import { NavixStore, navixStore } from '../store/NavixStore'
import { RightPanelState } from '../models/MapTypes'
import { MapSelectPanel } from './MapSelectPanel'
import { ParamsPanel } from './ParamsPanel'
import { HeatmapPanel } from './HeatmapPanel'

@ComponentV2
export struct RightPanel {
  @Local store: NavixStore = navixStore

  build() {
    Column() {
      if (this.store.rightPanelState === RightPanelState.MAP_SELECT) {
        MapSelectPanel()
      } else if (this.store.rightPanelState === RightPanelState.PARAMS) {
        ParamsPanel()
      } else if (this.store.rightPanelState === RightPanelState.HEATMAP) {
        HeatmapPanel()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.navix_bg_panel'))
  }
}
