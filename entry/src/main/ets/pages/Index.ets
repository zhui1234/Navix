import { TitleBar } from '../components/TitleBar'
import { StatusBar } from '../components/StatusBar'
import { LeftTriggerBar } from '../components/LeftTriggerBar'
import { RightTriggerBar } from '../components/RightTriggerBar'
import { LeftPanel } from '../components/LeftPanel'
import { RightPanel } from '../components/RightPanel'
import { MainCanvas } from '../components/MainCanvas'
import { navixStore} from '../store/NavixStore'
import { LeftPanelState, RightPanelState } from '../models/MapTypes'

@Entry
@Component
struct Index {
  @StorageLink('leftPanelWidth') leftPanelWidth: number = 0
  @StorageLink('rightPanelWidth') rightPanelWidth: number = 0

  aboutToAppear(): void {
    AppStorage.setOrCreate('leftPanelWidth', 0)
    AppStorage.setOrCreate('rightPanelWidth', 0)
  }

  getLeftPanelWidth(): number {
    return navixStore.leftPanelState === LeftPanelState.COLLAPSED ? 0 : 180
  }

  getRightPanelWidth(): number {
    return navixStore.rightPanelState === RightPanelState.COLLAPSED ? 0 : 180
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
          .width(this.getLeftPanelWidth())
          .height('100%')

          MainCanvas()

          Column() {
            RightPanel()
          }
          .width(this.getRightPanelWidth())
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
