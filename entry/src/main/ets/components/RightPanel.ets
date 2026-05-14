import { NavixStore, navixStore } from '../store/NavixStore'
import { RightPanelState } from '../models/MapTypes'
import { MapSettingsPanel } from './MapSettingsPanel'
import { VisualizationPanel } from './VisualizationPanel'
import { HeatmapPanel } from './HeatmapPanel'

@ComponentV2
export struct RightPanel {
  @Local store: NavixStore = navixStore

  build() {
    Column() {
      if (this.store.rightPanelState === RightPanelState.MAP_SETTINGS) {
        MapSettingsPanel()
      } else if (this.store.rightPanelState === RightPanelState.VISUALIZATION) {
        VisualizationPanel()
      } else if (this.store.rightPanelState === RightPanelState.HEATMAP) {
        HeatmapPanel()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.store.getColor('navix_bg_panel'))
  }
}
