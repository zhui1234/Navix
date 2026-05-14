import { NavixStore } from '../store/NavixStore'
import { navixStore } from '../store/NavixStore'

@ComponentV2
export struct TitleBar {
  @Local store: NavixStore = navixStore

  build() {
    Row() {
      Row({ space: 8 }) {
        Image($r('app.media.app_icon'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
        SymbolGlyph($r('sys.symbol.square_grid_2x2'))
          .fontSize(20)
          .fontColor([this.store.getColor('navix_icon_color')])
        SymbolGlyph($r('sys.symbol.lightbulb'))
          .fontSize(20)
          .fontColor([this.store.getColor('navix_icon_color')])
      }
      Blank()
      Row({ space: 6 }) {
        SymbolGlyph($r('sys.symbol.backward_end_fill'))
          .fontSize(18)
          .fontColor([this.store.getColor('navix_icon_color')])
          .onClick(() => {
            this.store.currentStep = 0
          })
        SymbolGlyph($r('sys.symbol.play_fill'))
          .fontSize(18)
          .fontColor([this.store.getColor('navix_icon_color')])
        SymbolGlyph($r('sys.symbol.forward_end_fill'))
          .fontSize(18)
          .fontColor([this.store.getColor('navix_icon_color')])
          .onClick(() => {
            this.store.nextStep()
          })
        Text(`步骤 ${this.store.currentStep}/${this.store.searchSteps.length}`)
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
      }
      Blank()
      Row({ space: 10 }) {
        SymbolGlyph($r('sys.symbol.gearshape'))
          .fontSize(20)
          .fontColor([this.store.getColor('navix_icon_color')])
        SymbolGlyph($r('sys.symbol.minus'))
          .fontSize(20)
          .fontColor([this.store.getColor('navix_icon_color')])
        SymbolGlyph($r('sys.symbol.square'))
          .fontSize(20)
          .fontColor([this.store.getColor('navix_icon_color')])
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(20)
          .fontColor([this.store.getColor('navix_icon_color')])
      }
    }
    .width('100%')
    .height(48)
    .backgroundColor(this.store.getColor('navix_bg_toolbar'))
    .padding({ left: 8, right: 8 })
    .alignItems(VerticalAlign.Center)
  }
}