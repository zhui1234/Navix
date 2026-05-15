import { NavixStore, navixStore } from '../store/NavixStore'
import { RightPanelState, AlgorithmType } from '../models/MapTypes'
import { MainCanvas } from './MainCanvas'

@ComponentV2
export struct VisualizationPanel {
  @Local store: NavixStore = navixStore

  formatElapsed(ms: number): string {
    if (!Number.isFinite(ms) || ms < 0) {
      return '0ms'
    }
    if (ms >= 1000) {
      return `${(ms / 1000).toFixed(2)}s`
    }
    return `${Math.round(ms)}ms`
  }

  getAlgoSummaryText(algo: AlgorithmType): string {
    if (!this.store.startPos || !this.store.endPos) {
      return '缺少起点/终点'
    }
    const result = this.store.getCompareResult(algo)
    if (!result) {
      if (algo === AlgorithmType.ASTAR || algo === AlgorithmType.DIJKSTRA) {
        return '未运行'
      }
      return '未实现'
    }
    if (!result.implemented) {
      return '未实现'
    }
    if (!result.found) {
      return '未找到路径'
    }
    return `path ${result.pathLength} | explored ${result.exploredCount} | time ${this.formatElapsed(result.elapsedMs)} | cost ${result.cost.toFixed(2)}`
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
        Text('请选择 1~3 个算法进行对比')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .padding({ left: 8, right: 8, top: 6 })
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.store.selectedAlgorithms, (algo: AlgorithmType) => {
              Column({ space: 6 }) {
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

                  Text(this.getAlgoSummaryText(algo))
                    .fontSize(10)
                    .fontColor(this.store.getColor('navix_text_secondary'))
                }
                .width('100%')

                MainCanvas({ algorithm: algo })
                  .width('100%')
                  .height(220)
              }
              .width('100%')
              .padding(8)
              .borderRadius(8)
              .border({ width: 1, color: this.store.getColor('navix_border_color') })
              .backgroundColor(this.store.getColor('navix_bg_canvas'))
            }, (algo: AlgorithmType) => `${algo}`)
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 6 })
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
  }
}
