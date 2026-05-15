import { NavixStore, navixStore } from '../store/NavixStore'
import { AlgorithmType, LeftPanelState } from '../models/MapTypes'

@ComponentV2
export struct AlgorithmsPanel {
  @Local store: NavixStore = navixStore
  @Local hoveredAlgorithm: AlgorithmType | null = null
  @Local showCommonAlgorithms: boolean = true
  @Local showOtherAlgorithms: boolean = true
  @Local hoveredCommon: boolean = false
  @Local hoveredOther: boolean = false

  build() {
    Column({ space: 6 }) {
      Row() {
        Text('算法栏')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.store.getColor('navix_text_primary'))

        Blank()

        Text(`${this.store.selectedAlgorithms.length}/3`)
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .margin({ right: 8 })

        SymbolGlyph($r('sys.symbol.minus'))
          .fontSize(14)
          .fontColor([this.store.getColor('navix_icon_color')])
          .onClick(() => {
            this.store.toggleLeftPanel(LeftPanelState.ALGORITHMS)
          })
      }
      .width('100%')
      .padding({ top: 10, left: 8, right: 8 })

      Row() {
        SymbolGlyph(this.showCommonAlgorithms ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_right'))
          .fontSize(12)
          .fontColor([this.store.getColor('navix_text_secondary')])
          .width(16)

        Text('常用算法')
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))
      }
      .width('100%')
      .padding({ left: 4, top: 6, bottom: 4 })
      .borderRadius(4)
      .backgroundColor(this.hoveredCommon ? this.store.getColor('navix_border_color') : Color.Transparent)
      .onHover((isHover: boolean) => {
        this.hoveredCommon = isHover
      })
      .onClick(() => {
        this.showCommonAlgorithms = !this.showCommonAlgorithms
      })

      if (this.showCommonAlgorithms) {
        this.AlgorithmButton(AlgorithmType.ASTAR, 'A* 算法', '最佳优先搜索，综合考虑距离和启发式，效率高')
        this.AlgorithmButton(AlgorithmType.DIJKSTRA, 'Dijkstra', '经典最短路径算法，保证找到最优解')
        this.AlgorithmButton(AlgorithmType.BFS, 'BFS', '广度优先搜索，逐层扩展节点')
        this.AlgorithmButton(AlgorithmType.DFS, 'DFS', '深度优先搜索，沿一条路径深入搜索')
      }

      Divider()
        .color(this.store.getColor('navix_border_color'))
        .margin({ left: 8, right: 8, top: 2, bottom: 2 })

      Row() {
        SymbolGlyph(this.showOtherAlgorithms ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_right'))
          .fontSize(12)
          .fontColor([this.store.getColor('navix_text_secondary')])
          .width(16)

        Text('其他算法')
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))
      }
      .width('100%')
      .padding({ left: 4, top: 6, bottom: 4 })
      .borderRadius(4)
      .backgroundColor(this.hoveredOther ? this.store.getColor('navix_border_color') : Color.Transparent)
      .onHover((isHover: boolean) => {
        this.hoveredOther = isHover
      })
      .onClick(() => {
        this.showOtherAlgorithms = !this.showOtherAlgorithms
      })

      if (this.showOtherAlgorithms) {
        this.AlgorithmButton(AlgorithmType.GREEDY_BFS, '贪心 BFS', '只考虑启发式距离，速度快但不保证最优')
        this.AlgorithmButton(AlgorithmType.IDA_STAR, 'IDA*', '迭代加深 A*，内存占用低，可能更慢')
        this.AlgorithmButton(AlgorithmType.DSTAR_LITE, 'D* Lite', '动态路径规划，支持地图变化')
        this.AlgorithmButton(AlgorithmType.THETA_STAR, 'Theta*', '任意角度路径，允许对角线移动')
        this.AlgorithmButton(AlgorithmType.RRT, 'RRT', '快速随机树，适合高维空间')
        this.AlgorithmButton(AlgorithmType.PRM, 'PRM', '概率路线图，基于采样的规划')
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 6, right: 6, bottom: 10 })
    .alignItems(HorizontalAlign.Start)
  }

  isSelected(algo: AlgorithmType): boolean {
    return this.store.selectedAlgorithms.indexOf(algo) >= 0
  }

  @Builder
  AlgorithmButton(algo: AlgorithmType, name: string, hint: string) {
    Column({ space: 2 }) {
      Text(name)
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_primary'))
        .fontWeight(this.isSelected(algo) ? FontWeight.Medium : FontWeight.Normal)

      if (this.hoveredAlgorithm === algo) {
        Text(hint)
          .fontSize(10)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .lineHeight(13)
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 7, bottom: 7 })
    .borderRadius(6)
    .backgroundColor(this.isSelected(algo) ? this.store.getColor('navix_button_active') : (this.hoveredAlgorithm === algo ? this.store.getColor('navix_border_color') : Color.Transparent))
    .onHover((isHover: boolean) => {
      this.hoveredAlgorithm = isHover ? algo : null
    })
    .onClick(() => {
      this.store.toggleCompareAlgorithm(algo)
    })
  }
}
