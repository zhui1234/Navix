import { NavixStore, navixStore } from '../store/NavixStore'
import { ConfigurationConstant } from '@kit.AbilityKit'

@ComponentV2
export struct StatusBar {
  @Local store: NavixStore = navixStore
  @Local zoomText: string = `${navixStore.canvasZoomPercent}`
  @Local zoomValid: boolean = true
  @Local applyZoomTimerId: number = -1

  aboutToAppear(): void {
    this.zoomText = `${this.store.canvasZoomPercent}`
    this.zoomValid = true
  }

  parseZoomPercent(value: string): number {
    const trimmed = value.trim()
    if (trimmed.length === 0) {
      return 0
    }
    const normalized = trimmed.replace(/[０-９]/g, (ch: string) => {
      return String.fromCharCode(ch.charCodeAt(0) - 0xFEE0)
    })
    if (!/^\d+$/.test(normalized)) {
      return 0
    }
    const num = Number(normalized)
    return num >= 10 && num <= 300 ? num : 0
  }

  applyZoomPercent(): void {
    const percent = this.parseZoomPercent(this.zoomText)
    this.zoomValid = percent > 0
    if (percent > 0) {
      this.store.setCanvasZoomPercent(percent)
      this.zoomText = `${percent}`
    }
  }

  scheduleApplyZoomPercent(): void {
    if (this.applyZoomTimerId >= 0) {
      clearTimeout(this.applyZoomTimerId)
      this.applyZoomTimerId = -1
    }
    this.applyZoomTimerId = setTimeout(() => {
      this.applyZoomTimerId = -1
      this.applyZoomPercent()
    }, 0)
  }

  build() {
    Row() {
      SymbolGlyph($r('sys.symbol.moon_fill'))
        .fontSize(18)
        .fontColor([this.store.theme === 'light' ? '#000000' : '#FFFFFF'])
        .onClick(() => {
          this.toggleTheme()
        })

      Row({ space: 4 }) {
        Text(`● ${this.store.statusText}`)
          .fontSize(12)
          .fontColor(this.store.getColor('navix_node_start'))
        Text(' | ')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text(`地图大小: ${this.store.mapData.cols}×${this.store.mapData.rows}`)
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text(' | ')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text(`搜索节点: ${this.store.searchedNodes}`)
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text(' | ')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text(`路径长度: ${this.store.pathLength}`)
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text(' | ')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text(`时间: ${this.store.elapsedTime}ms`)
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text(' | ')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
      .margin({ left: 10, right: 10 })

      Row({ space: 6 }) {
        Text('缩放')
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))

        Slider({ value: this.store.canvasZoomPercent, min: 10, max: 300, step: 1 })
          .width(110)
          .onChange((value: number) => {
            this.store.setCanvasZoomPercent(Math.round(value))
            this.zoomText = `${this.store.canvasZoomPercent}`
            this.zoomValid = true
          })

        TextInput({ text: this.zoomText, placeholder: '100' })
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_primary'))
          .caretColor(this.store.getColor('navix_accent_highlight'))
          .type(InputType.Number)
          .width(44)
          .height(24)
          .backgroundColor(this.store.getColor('navix_bg_canvas'))
          .border({ width: 1, color: this.zoomValid ? this.store.getColor('navix_border_color') : this.store.getColor('navix_node_end') })
          .borderRadius(4)
          .padding({ left: 6, right: 6 })
          .onChange((value: string) => {
            this.zoomText = value
            this.zoomValid = this.parseZoomPercent(this.zoomText) > 0
          })
          .onSubmit((_enterKey: EnterKeyType, event: SubmitEvent) => {
            this.zoomText = event.text
            this.scheduleApplyZoomPercent()
          })

        Text('%')
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))
      }
    }
    .width('100%')
    .height(36)
    .backgroundColor(this.store.getColor('navix_bg_toolbar'))
    .padding({ left: 12, right: 12 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  toggleTheme() {
    const currentTheme = this.store.theme
    const newTheme = currentTheme === 'light' ? 'dark' : 'light'
    const newColorMode = newTheme === 'light' 
      ? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT 
      : ConfigurationConstant.ColorMode.COLOR_MODE_DARK
    
    try {
      const context = getContext(this)
      context.getApplicationContext().setColorMode(newColorMode)
      this.store.toggleTheme()
    } catch (err) {
      console.error('Failed to set color mode', JSON.stringify(err))
      this.store.toggleTheme()
    }
  }
}
