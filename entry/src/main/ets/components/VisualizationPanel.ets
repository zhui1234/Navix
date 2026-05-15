import { NavixStore, navixStore } from '../store/NavixStore'
import { RightPanelState, AlgorithmType, VisualizationMode } from '../models/MapTypes'

@ComponentV2
export struct VisualizationPanel {
  @Local store: NavixStore = navixStore
  @Local showTimeline: boolean = true
  @Local hoveredTimeline: boolean = false

  isSelected(mode: VisualizationMode, algo: AlgorithmType): boolean {
    return this.store.visualizationMode === mode && this.store.visualizationAlgorithm === algo
  }

  @Builder
  AlgoOption(mode: VisualizationMode, algo: AlgorithmType) {
    Row({ space: 8 }) {
      Column()
        .width(10)
        .height(10)
        .borderRadius(2)
        .backgroundColor(this.store.getAlgorithmPathColor(algo))

      Text(this.store.getAlgorithmName(algo))
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_primary'))

      Blank()

      if (this.isSelected(mode, algo)) {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize(12)
          .fontColor([this.store.getColor('navix_accent_highlight')])
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .borderRadius(6)
    .border({ width: this.isSelected(mode, algo) ? 1 : 0, color: this.store.getColor('navix_accent_highlight') })
    .backgroundColor(this.isSelected(mode, algo) ? this.store.getColor('navix_border_color') : Color.Transparent)
    .onClick(() => {
      if (this.isSelected(mode, algo)) {
        this.store.clearVisualization()
        return
      }
      this.store.startVisualization(mode, algo)
    })
  }

  build() {
    Column({ space: 8 }) {
      Row() {
        Text('可视化')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.store.getColor('navix_text_primary'))

        Blank()

        SymbolGlyph($r('sys.symbol.minus'))
          .fontSize(14)
          .fontColor([this.store.getColor('navix_icon_color')])
          .onClick(() => {
            this.store.toggleRightPanel(RightPanelState.VISUALIZATION)
          })
      }
      .width('100%')
      .padding({ top: 10, left: 8, right: 8 })

      if (this.store.selectedAlgorithms.length === 0) {
        Text('请先在算法栏选择 1~3 个算法')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .padding({ left: 8, right: 8, top: 6 })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            Row() {
              SymbolGlyph(this.showTimeline ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_right'))
                .fontSize(12)
                .fontColor([this.store.getColor('navix_text_secondary')])
                .width(16)

              Text('时间轴')
                .fontSize(11)
                .fontColor(this.store.getColor('navix_text_secondary'))
            }
            .width('100%')
            .padding({ left: 4, top: 8, bottom: 8 })
            .borderRadius(6)
            .backgroundColor(this.hoveredTimeline ? this.store.getColor('navix_border_color') : Color.Transparent)
            .onHover((isHover: boolean) => {
              this.hoveredTimeline = isHover
            })
            .onClick(() => {
              this.showTimeline = !this.showTimeline
            })

            if (this.showTimeline) {
              Text('选择一个算法后，在主画布生成时间轴；顶部按键可播放/暂停、上一步/下一步')
                .fontSize(10)
                .fontColor(this.store.getColor('navix_text_secondary'))
                .padding({ left: 6, right: 6, bottom: 4 })

              ForEach(this.store.selectedAlgorithms, (algo: AlgorithmType) => {
                this.AlgoOption(VisualizationMode.TIMELINE, algo)
              }, (algo: AlgorithmType) => `${algo}`)
            }

            Blank()
              .layoutWeight(1)
          }
          .width('100%')
          .height('100%')
          .padding({ left: 8, right: 8, top: 6 })
          .justifyContent(FlexAlign.Start)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.None)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 6, right: 6, bottom: 10 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}
