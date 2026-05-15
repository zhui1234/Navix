import { NavixStore, navixStore } from '../store/NavixStore'
import { AlgorithmType, AlgorithmSpec, LeftPanelState } from '../models/MapTypes'

@ComponentV2
export struct AlgorithmsPanel {
  @Local store: NavixStore = navixStore
  @Local hoveredAlgorithmId: string | null = null
  @Local showCommonAlgorithms: boolean = true
  @Local showOtherAlgorithms: boolean = true
  @Local showIDAStar: boolean = false
  @Local showAStar: boolean = false
  @Local hoveredCommon: boolean = false
  @Local hoveredOther: boolean = false
  @Local hoveredIDAStar: boolean = false
  @Local idaWeightText: string = '1.00'
  @Local idaWeightValid: boolean = true

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
        this.AStarGroup()
        this.IDAStarGroup()
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
        this.AlgorithmButton(this.store.createSimpleSpec(AlgorithmType.DIJKSTRA), 'Dijkstra', '经典最短路径算法，保证找到最优解')
        this.AlgorithmButton(this.store.createSimpleSpec(AlgorithmType.BFS), 'BFS', '广度优先搜索，逐层扩展节点')
        this.AlgorithmButton(this.store.createSimpleSpec(AlgorithmType.DFS), 'DFS', '深度优先搜索，沿一条路径深入搜索')
        this.AlgorithmButton(this.store.createSimpleSpec(AlgorithmType.GREEDY_BFS), '贪心 BFS', '只考虑启发式距离，速度快但不保证最优')
        this.AlgorithmButton(this.store.createSimpleSpec(AlgorithmType.DSTAR_LITE), 'D* Lite', '动态路径规划，支持地图变化')
        this.AlgorithmButton(this.store.createSimpleSpec(AlgorithmType.THETA_STAR), 'Theta*', '任意角度路径规划')
        this.AlgorithmButton(this.store.createSimpleSpec(AlgorithmType.RRT), 'RRT', '快速随机树，适合高维空间')
        this.AlgorithmButton(this.store.createSimpleSpec(AlgorithmType.PRM), 'PRM', '概率路线图，基于采样的规划')
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 6, right: 6, bottom: 10 })
    .alignItems(HorizontalAlign.Start)
  }

  parseWeight(value: string): number {
    const trimmed = value.trim()
    if (trimmed.length === 0) {
      return 0
    }
    const normalized = trimmed.replace(/[０-９．]/g, (ch: string) => {
      if (ch === '．') {
        return '.'
      }
      return String.fromCharCode(ch.charCodeAt(0) - 0xFEE0)
    })
    if (!/^\d+(\.\d+)?$/.test(normalized)) {
      return 0
    }
    const num = Number(normalized)
    return num > 0 && num <= 10 ? num : 0
  }

  isSelected(spec: AlgorithmSpec): boolean {
    return this.store.isSelectedAlgorithm(spec)
  }

  isTypeSelected(type: AlgorithmType): boolean {
    const prev = this.store.selectedAlgorithms
    for (let i = 0; i < prev.length; i++) {
      if (prev[i].type === type) {
        return true
      }
    }
    return false
  }

  private getDefaultIDAStarWeight(): number {
    const prev = this.store.idaStarWeights
    if (prev.length === 0) {
      return 1.0
    }
    for (let i = 0; i < prev.length; i++) {
      if (Math.abs(prev[i] - 1.0) < 1e-6) {
        return prev[i]
      }
    }
    return prev[0]
  }

  getAStarDefaultHint(): string {
    return '默认启发函数：Manhattan'
  }

  getIDAStarDefaultHint(): string {
    const w = this.getDefaultIDAStarWeight()
    return `默认权重：${this.store.formatWeight(w)}`
  }

  @Builder
  AStarGroup() {
    Row() {
      Column({ space: 2 }) {
        Text('A*')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_primary'))
          .fontWeight(this.isTypeSelected(AlgorithmType.ASTAR) ? FontWeight.Medium : FontWeight.Normal)

        if (this.hoveredAlgorithmId === 'group-astar') {
          Text(this.getAStarDefaultHint())
            .fontSize(10)
            .fontColor(this.store.getColor('navix_text_secondary'))
            .lineHeight(13)
        }
      }
      .layoutWeight(1)
      .onClick(() => {
        this.store.toggleCompareAlgorithm(this.store.createAStarSpec('manhattan'))
      })

      SymbolGlyph(this.showAStar ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_left'))
        .fontSize(14)
        .fontColor([this.store.getColor('navix_icon_color')])
        .onClick(() => {
          this.showAStar = !this.showAStar
        })
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 7, bottom: 7 })
    .borderRadius(6)
    .backgroundColor(this.isTypeSelected(AlgorithmType.ASTAR) ? this.store.getColor('navix_button_active') : (this.hoveredAlgorithmId === 'group-astar' ? this.store.getColor('navix_border_color') : Color.Transparent))
    .onHover((isHover: boolean) => {
      this.hoveredAlgorithmId = isHover ? 'group-astar' : null
    })

    if (this.showAStar) {
      Column() {
        this.AlgorithmButton(this.store.createAStarSpec('manhattan'), this.store.getAlgorithmLabel(this.store.createAStarSpec('manhattan')), 'A* 启发函数：Manhattan')
      }
      .padding({ left: 10 })
      Column() {
        this.AlgorithmButton(this.store.createAStarSpec('euclidean'), this.store.getAlgorithmLabel(this.store.createAStarSpec('euclidean')), 'A* 启发函数：Euclidean')
      }
      .padding({ left: 10 })
      Column() {
        this.AlgorithmButton(this.store.createAStarSpec('chebyshev'), this.store.getAlgorithmLabel(this.store.createAStarSpec('chebyshev')), 'A* 启发函数：Chebyshev')
      }
      .padding({ left: 10 })
      Column() {
        this.AlgorithmButton(this.store.createAStarSpec('octile'), this.store.getAlgorithmLabel(this.store.createAStarSpec('octile')), 'A* 启发函数：Octile')
      }
      .padding({ left: 10 })
    }
  }

  @Builder
  AlgorithmButton(spec: AlgorithmSpec, name: string, hint: string) {
    Column({ space: 2 }) {
      Text(name)
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_primary'))
        .fontWeight(this.isSelected(spec) ? FontWeight.Medium : FontWeight.Normal)

      if (this.hoveredAlgorithmId === spec.id) {
        Text(hint)
          .fontSize(10)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .lineHeight(13)
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 7, bottom: 7 })
    .borderRadius(6)
    .backgroundColor(this.isSelected(spec) ? this.store.getColor('navix_button_active') : (this.hoveredAlgorithmId === spec.id ? this.store.getColor('navix_border_color') : Color.Transparent))
    .onHover((isHover: boolean) => {
      this.hoveredAlgorithmId = isHover ? spec.id : null
    })
    .onClick(() => {
      this.store.toggleCompareAlgorithm(spec)
    })
  }

  @Builder
  IDAStarGroup() {
    Row() {
      Column({ space: 2 }) {
        Text('IDA*')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_primary'))
          .fontWeight(this.isTypeSelected(AlgorithmType.IDA_STAR) ? FontWeight.Medium : FontWeight.Normal)

        if (this.hoveredAlgorithmId === 'group-ida') {
          Text(this.getIDAStarDefaultHint())
            .fontSize(10)
            .fontColor(this.store.getColor('navix_text_secondary'))
            .lineHeight(13)
        }
      }
      .layoutWeight(1)
      .onClick(() => {
        const w = this.getDefaultIDAStarWeight()
        this.store.toggleCompareAlgorithm(this.store.createIDAStarSpec(w))
      })

      SymbolGlyph(this.showIDAStar ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_left'))
        .fontSize(14)
        .fontColor([this.store.getColor('navix_icon_color')])
        .onClick(() => {
          this.showIDAStar = !this.showIDAStar
        })
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 7, bottom: 7 })
    .borderRadius(6)
    .backgroundColor(this.isTypeSelected(AlgorithmType.IDA_STAR) ? this.store.getColor('navix_button_active') : (this.hoveredAlgorithmId === 'group-ida' ? this.store.getColor('navix_border_color') : Color.Transparent))
    .onHover((isHover: boolean) => {
      this.hoveredAlgorithmId = isHover ? 'group-ida' : null
      this.hoveredIDAStar = isHover
    })

    if (this.showIDAStar) {
      Text('可添加多个权重变体（w），每个变体视为独立算法')
        .fontSize(10)
        .fontColor(this.store.getColor('navix_text_secondary'))
        .padding({ left: 20, right: 10, bottom: 4 })

      Row({ space: 6 }) {
        TextInput({ text: this.idaWeightText, placeholder: '1.00' })
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_primary'))
          .caretColor(this.store.getColor('navix_accent_highlight'))
          .width(72)
          .height(26)
          .backgroundColor(this.store.getColor('navix_bg_canvas'))
          .border({ width: 1, color: this.idaWeightValid ? this.store.getColor('navix_border_color') : this.store.getColor('navix_node_end') })
          .borderRadius(4)
          .padding({ left: 6, right: 6 })
          .onChange((value: string) => {
            this.idaWeightText = value
            this.idaWeightValid = this.parseWeight(value) > 0
          })

        SymbolGlyph($r('sys.symbol.plus'))
          .fontSize(14)
          .fontColor([this.store.getColor('navix_icon_color')])
          .onClick(() => {
            const w = this.parseWeight(this.idaWeightText)
            this.idaWeightValid = w > 0
            if (w > 0) {
              this.store.addIDAStarWeight(w)
              this.idaWeightText = this.store.formatWeight(w)
            }
          })
      }
      .padding({ left: 20, right: 10, bottom: 6 })

      ForEach(this.store.idaStarWeights, (w: number) => {
        Column() {
          this.AlgorithmButton(this.store.createIDAStarSpec(w), this.store.getAlgorithmLabel(this.store.createIDAStarSpec(w)), 'IDA* 权重变体')
        }
        .padding({ left: 10 })
      }, (w: number) => `${w}`)
    }
  }
}
