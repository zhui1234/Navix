import { TitleBar } from '../components/TitleBar'
import { StatusBar } from '../components/StatusBar'
import { LeftTriggerBar } from '../components/LeftTriggerBar'
import { RightTriggerBar } from '../components/RightTriggerBar'
import { LeftPanel } from '../components/LeftPanel'
import { RightPanel } from '../components/RightPanel'
import { MainCanvas } from '../components/MainCanvas'
import { SettingsCenterDialog } from '../components/SettingsCenterDialog'
import { TitleBarMenuOverlay } from '../components/TitleBarMenuOverlay'
import { NavixStore, navixStore } from '../store/NavixStore'
import { LeftPanelState, RightPanelState, VisualizationMode, AlgorithmType } from '../models/MapTypes'
import { KeyCode } from '@kit.InputKit'

@Entry
@ComponentV2
struct Index {
  @Local store: NavixStore = navixStore

  requestRootFocus(): void {
    try {
      this.getUIContext().getFocusController().requestFocus('navixRoot')
    } catch (_err) {
    }
  }

  aboutToAppear(): void {
    this.requestRootFocus()
  }

  getDigitKey(event: KeyEvent): number {
    const t = event.keyText
    if (t.length > 0) {
      for (let i = 0; i < t.length; i++) {
        const ch = t.charAt(i)
        if (ch >= '0' && ch <= '9') {
          return Number(ch)
        }
      }
    }
    const code = event.keyCode
    if (code >= 48 && code <= 57) {
      return code - 48
    }
    if (code >= 96 && code <= 105) {
      return code - 96
    }
    return 0
  }

  isPlusKey(event: KeyEvent): boolean {
    const t = event.keyText
    const tl = t.toLowerCase()
    const code = event.keyCode
    return t === '+' || t === '=' || t === '＋' || tl === 'equal' || tl === 'equals' || code === 43 || code === 107 || code === 187 || code === 2058
  }

  isMinusKey(event: KeyEvent): boolean {
    const t = event.keyText
    const tl = t.toLowerCase()
    const code = event.keyCode
    return t === '-' || t === '－' || t === '_' || tl === 'minus' || code === 45 || code === 109 || code === 189 || code === 2057
  }

  handleKeyDown(event: KeyEvent): boolean {
    if (event.keyCode === KeyCode.KEYCODE_SPACE || event.keyText === ' ' || event.keyText === 'Space') {
      if (this.store.visualizationMode !== VisualizationMode.NONE) {
        this.store.toggleVisualizationPlayback()
        return true
      }
      this.store.runCompare()
      return true
    }

    if (this.isPlusKey(event)) {
      this.store.setCanvasZoomPercent(this.store.canvasZoomPercent + 10)
      this.store.statusText = `缩放: ${this.store.canvasZoomPercent}%`
      return true
    }
    if (this.isMinusKey(event)) {
      this.store.setCanvasZoomPercent(this.store.canvasZoomPercent - 10)
      this.store.statusText = `缩放: ${this.store.canvasZoomPercent}%`
      return true
    }

    const digit = this.getDigitKey(event)
    if (digit === 1) {
      const spec = this.store.createAStarSpec('manhattan')
      this.store.toggleCompareAlgorithm(spec)
      this.store.statusText = `算法: ${this.store.getAlgorithmLabel(spec)}`
      return true
    }
    if (digit === 2) {
      const w = this.store.getDefaultIDAStarWeight()
      const spec = this.store.createIDAStarSpec(w)
      this.store.toggleCompareAlgorithm(spec)
      this.store.statusText = `算法: ${this.store.getAlgorithmLabel(spec)}`
      return true
    }
    if (digit === 3) {
      const spec = this.store.createSimpleSpec(AlgorithmType.DIJKSTRA)
      this.store.toggleCompareAlgorithm(spec)
      this.store.statusText = `算法: ${this.store.getAlgorithmLabel(spec)}`
      return true
    }
    return false
  }

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

      TitleBarMenuOverlay()
      SettingsCenterDialog()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.store.getColor('navix_bg_primary'))
    .id('navixRoot')
    .focusable(true)
    .defaultFocus(true)
    .focusOnTouch(true)
    .onAppear(() => {
      this.requestRootFocus()
    })
    .onClick(() => {
      this.requestRootFocus()
    })
    .onKeyEvent((event?: KeyEvent) => {
      if (!event) {
        return
      }
      if (event.type === KeyType.Down) {
        const handled = this.handleKeyDown(event)
        if (!handled) {
          this.store.statusText = `${event.keyText} (${event.keyCode})`
        }
      }
    })
  }
}
