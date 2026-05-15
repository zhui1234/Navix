import { TitleBar } from '../components/TitleBar'
import { StatusBar } from '../components/StatusBar'
import { LeftTriggerBar } from '../components/LeftTriggerBar'
import { RightTriggerBar } from '../components/RightTriggerBar'
import { LeftPanel } from '../components/LeftPanel'
import { RightPanel } from '../components/RightPanel'
import { MainCanvas } from '../components/MainCanvas'
import { SettingsCenterDialog } from '../components/SettingsCenterDialog'
import { NavixStore, navixStore } from '../store/NavixStore'
import { LeftPanelState, RightPanelState } from '../models/MapTypes'

@Entry
@ComponentV2
struct Index {
  @Local store: NavixStore = navixStore

  @Computed
  get leftPanelWidth(): number {
    if (this.store.viewMode !== 'edit') {
      return 0
    }
    return this.store.leftPanelState === LeftPanelState.COLLAPSED ? 0 : 150
  }

  @Computed
  get rightPanelWidth(): number {
    if (this.store.viewMode !== 'edit') {
      return 0
    }
    if (this.store.rightPanelState === RightPanelState.COLLAPSED) {
      return 0
    }
    if (this.store.rightPanelState === RightPanelState.VISUALIZATION) {
      return 420
    }
    return 200
  }
  build() {
    Stack() {
      Column() {
        TitleBar()

        Row() {
          if (this.store.viewMode === 'edit') {
            LeftTriggerBar()
          }

          Column() {
            LeftPanel()
          }
          .width(this.leftPanelWidth)
          .height('100%')

          MainCanvas({ algorithm: null })
            .layoutWeight(1)
            .height('100%')

          Column() {
            RightPanel()
          }
          .width(this.rightPanelWidth)
          .height('100%')

          if (this.store.viewMode === 'edit') {
            RightTriggerBar()
          }
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)

        StatusBar()
      }
      .width('100%')
      .height('100%')

      SettingsCenterDialog()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.store.getColor('navix_bg_primary'))
  }
}
