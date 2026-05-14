import { TitleBar } from '../components/TitleBar'
import { StatusBar } from '../components/StatusBar'
import { LeftTriggerBar } from '../components/LeftTriggerBar'
import { RightTriggerBar } from '../components/RightTriggerBar'
import { LeftPanel } from '../components/LeftPanel'
import { RightPanel } from '../components/RightPanel'
import { MainCanvas } from '../components/MainCanvas'
import { NavixStore, navixStore } from '../store/NavixStore'
import { LeftPanelState, RightPanelState } from '../models/MapTypes'

@Entry
@ComponentV2
struct Index {
  @Local store: NavixStore = navixStore

  @Computed
  get leftPanelWidth(): number {
    return this.store.leftPanelState === LeftPanelState.COLLAPSED ? 0 : 180
  }

  @Computed
  get rightPanelWidth(): number {
    return this.store.rightPanelState === RightPanelState.COLLAPSED ? 0 : 180
  }
  build() {
    Column() {
      TitleBar()

      Column() {
        Row() {
          LeftTriggerBar()

          Column() {
            LeftPanel()
          }
          .width(this.leftPanelWidth)
          .height('100%')

          MainCanvas()

          Column() {
            RightPanel()
          }
          .width(this.rightPanelWidth)
          .height('100%')

          RightTriggerBar()
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height(0)
      .layoutWeight(1)

      StatusBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.navix_bg_primary'))
  }
}
