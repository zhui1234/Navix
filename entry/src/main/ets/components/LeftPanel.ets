import { NavixStore, navixStore } from '../store/NavixStore'
import { LeftPanelState } from '../models/MapTypes'
import { ToolsPanel } from './ToolsPanel'
import { AlgorithmsPanel } from './AlgorithmsPanel'

@ComponentV2
export struct LeftPanel {
  @Local store: NavixStore = navixStore

  build() {
    Column() {
      if (this.store.leftPanelState === LeftPanelState.TOOLS) {
        ToolsPanel()
      } else if (this.store.leftPanelState === LeftPanelState.ALGORITHMS) {
        AlgorithmsPanel()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.navix_bg_panel'))
  }
}
