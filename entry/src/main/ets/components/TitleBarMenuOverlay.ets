import { NavixStore, navixStore } from '../store/NavixStore'
import { ToolType, LeftPanelState, RightPanelState, MapType, AlgorithmType } from '../models/MapTypes'

const MENU_START_X: number = 68
const MENU_ITEM_W: number = 64
const MENU_ITEM_GAP: number = 6
const MENU_TOP_Y: number = 48

@ComponentV2
export struct TitleBarMenuOverlay {
  @Local store: NavixStore = navixStore
  @Local hoveredKey: string | null = null

  withAlpha(color: string, alphaHex: string): string {
    const hex = color.startsWith('#') ? color.slice(1) : color
    if (hex.length === 6) {
      return `#${alphaHex}${hex}`
    }
    return color
  }

  getActiveIndex(): number {
    if (this.store.titleMenuActive === 'file') {
      return 0
    }
    if (this.store.titleMenuActive === 'tools') {
      return 1
    }
    if (this.store.titleMenuActive === 'algorithms') {
      return 2
    }
    if (this.store.titleMenuActive === 'map') {
      return 3
    }
    if (this.store.titleMenuActive === 'help') {
      return 4
    }
    return 0
  }

  getMenuX(): number {
    return MENU_START_X + this.getActiveIndex() * (MENU_ITEM_W + MENU_ITEM_GAP)
  }

  close(): void {
    this.store.closeTitleMenu()
  }

  runAction(action: () => void): void {
    action()
    this.close()
  }

  @Builder
  MenuAction(label: string, selected: boolean, key: string, action: () => void) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor(this.store.getColor('navix_text_primary'))
      Blank()
      if (selected) {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize(14)
          .fontColor([this.store.getColor('navix_accent_highlight')])
      }
    }
    .width('100%')
    .height(32)
    .padding({ left: 10, right: 10 })
    .borderRadius(6)
    .backgroundColor(this.hoveredKey === key ? this.store.getColor('navix_border_color') : Color.Transparent)
    .onHover((isHover: boolean) => {
      this.hoveredKey = isHover ? key : null
    })
    .onClick(() => {
      this.runAction(action)
    })
  }

  @Builder
  FileMenu() {
    Column({ space: 6 }) {
      Text('文件菜单占位')
        .fontSize(13)
        .fontColor(this.store.getColor('navix_text_secondary'))
        .padding({ left: 10, right: 10, top: 10, bottom: 10 })
    }
    .width('100%')
  }

  @Builder
  HelpMenu() {
    Column({ space: 4 }) {
      this.MenuAction('使用说明', false, 'help-usage', () => {
        this.store.openCenterDialog('usage')
      })
      this.MenuAction('快捷键列表', false, 'help-shortcuts', () => {
        this.store.openCenterDialog('shortcuts')
      })
      this.MenuAction('关于', false, 'help-about', () => {
        this.store.openCenterDialog('about')
      })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  ToolsMenu() {
    Column({ space: 4 }) {
      this.MenuAction('打开工具栏', this.store.leftPanelState === LeftPanelState.TOOLS, 'tools-open', () => {
        this.store.toggleLeftPanel(LeftPanelState.TOOLS)
      })
      Divider()
        .color(this.store.getColor('navix_border_color'))
        .margin({ left: 10, right: 10, top: 4, bottom: 4 })
      if (this.store.currentMapType === MapType.GRAPH) {
        this.MenuAction('浏览', this.store.currentTool === ToolType.SELECT, 'tools-graph-select', () => this.store.setTool(ToolType.SELECT))
        this.MenuAction('节点', this.store.currentTool === ToolType.GRAPH_NODE, 'tools-graph-node', () => this.store.setTool(ToolType.GRAPH_NODE))
        this.MenuAction('删除', this.store.currentTool === ToolType.GRAPH_ERASER, 'tools-graph-eraser', () => this.store.setTool(ToolType.GRAPH_ERASER))
        Divider()
          .color(this.store.getColor('navix_border_color'))
          .margin({ left: 10, right: 10, top: 4, bottom: 4 })
        this.MenuAction('清空节点', false, 'tools-graph-clear', () => this.store.clearGraphNodes())
      } else {
        this.MenuAction('选择', this.store.currentTool === ToolType.SELECT, 'tools-select', () => this.store.setTool(ToolType.SELECT))
        this.MenuAction('起点', this.store.currentTool === ToolType.START, 'tools-start', () => this.store.setTool(ToolType.START))
        this.MenuAction('终点', this.store.currentTool === ToolType.END, 'tools-end', () => this.store.setTool(ToolType.END))
        this.MenuAction('障碍', this.store.currentTool === ToolType.OBSTACLE, 'tools-obstacle', () => this.store.setTool(ToolType.OBSTACLE))
        this.MenuAction('橡皮', this.store.currentTool === ToolType.ERASER, 'tools-eraser', () => this.store.setTool(ToolType.ERASER))
        Divider()
          .color(this.store.getColor('navix_border_color'))
          .margin({ left: 10, right: 10, top: 4, bottom: 4 })
        this.MenuAction('随机生成', false, 'tools-random', () => this.store.generateRandomObstacles())
      }
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  AlgorithmsMenu() {
    Column({ space: 4 }) {
      this.MenuAction('打开算法栏', this.store.leftPanelState === LeftPanelState.ALGORITHMS, 'algo-open', () => {
        this.store.toggleLeftPanel(LeftPanelState.ALGORITHMS)
      })
      Divider()
        .color(this.store.getColor('navix_border_color'))
        .margin({ left: 10, right: 10, top: 4, bottom: 4 })
      this.MenuAction('A* (Manhattan)', this.store.isSelectedAlgorithm(this.store.createAStarSpec('manhattan')), 'algo-astar-m', () => {
        this.store.toggleCompareAlgorithm(this.store.createAStarSpec('manhattan'))
      })
      this.MenuAction('Dijkstra', this.store.isSelectedAlgorithm(this.store.createSimpleSpec(AlgorithmType.DIJKSTRA)), 'algo-dijkstra', () => {
        this.store.toggleCompareAlgorithm(this.store.createSimpleSpec(AlgorithmType.DIJKSTRA))
      })
      this.MenuAction('BFS', this.store.isSelectedAlgorithm(this.store.createSimpleSpec(AlgorithmType.BFS)), 'algo-bfs', () => {
        this.store.toggleCompareAlgorithm(this.store.createSimpleSpec(AlgorithmType.BFS))
      })
      this.MenuAction('DFS', this.store.isSelectedAlgorithm(this.store.createSimpleSpec(AlgorithmType.DFS)), 'algo-dfs', () => {
        this.store.toggleCompareAlgorithm(this.store.createSimpleSpec(AlgorithmType.DFS))
      })
      this.MenuAction('贪心 BFS', this.store.isSelectedAlgorithm(this.store.createSimpleSpec(AlgorithmType.GREEDY_BFS)), 'algo-greedy', () => {
        this.store.toggleCompareAlgorithm(this.store.createSimpleSpec(AlgorithmType.GREEDY_BFS))
      })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  MapMenu() {
    Column({ space: 4 }) {
      this.MenuAction('打开地图设置', this.store.rightPanelState === RightPanelState.MAP_SETTINGS, 'map-open', () => {
        this.store.toggleRightPanel(RightPanelState.MAP_SETTINGS)
      })
      Divider()
        .color(this.store.getColor('navix_border_color'))
        .margin({ left: 10, right: 10, top: 4, bottom: 4 })
      this.MenuAction('栅格图', this.store.currentMapType === MapType.GRID, 'map-grid', () => this.store.setMapType(MapType.GRID))
      this.MenuAction('关系图', this.store.currentMapType === MapType.GRAPH, 'map-graph', () => this.store.setMapType(MapType.GRAPH))
      this.MenuAction('2.5D地图', this.store.currentMapType === MapType.MAP_2D5, 'map-2d5', () => this.store.setMapType(MapType.MAP_2D5))
      this.MenuAction('3D地图', this.store.currentMapType === MapType.MAP_3D, 'map-3d', () => this.store.setMapType(MapType.MAP_3D))
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  build() {
    if (this.store.titleMenuActive !== 'none') {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.close()
          })

        Column() {
          if (this.store.titleMenuActive === 'file') {
            this.FileMenu()
          } else if (this.store.titleMenuActive === 'tools') {
            this.ToolsMenu()
          } else if (this.store.titleMenuActive === 'algorithms') {
            this.AlgorithmsMenu()
          } else if (this.store.titleMenuActive === 'map') {
            this.MapMenu()
          } else if (this.store.titleMenuActive === 'help') {
            this.HelpMenu()
          }
        }
        .width(220)
        .borderRadius(8)
        .backgroundColor(this.store.getColor('navix_bg_panel'))
        .border({ width: 1, color: this.store.getColor('navix_border_color') })
        .shadow({ radius: 16, color: this.withAlpha('#000000', this.store.theme === 'light' ? '22' : '66'), offsetX: 0, offsetY: 8 })
        .position({ x: this.getMenuX(), y: MENU_TOP_Y })
        .onClick(() => {})
      }
      .width('100%')
      .height('100%')
    }
  }
}
