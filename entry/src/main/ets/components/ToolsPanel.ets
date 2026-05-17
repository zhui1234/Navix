import { NavixStore, navixStore } from '../store/NavixStore'
import { ToolType, LeftPanelState, MapType } from '../models/MapTypes'

@ComponentV2
export struct ToolsPanel {
  @Local store: NavixStore = navixStore
  @Local hoveredTool: ToolType | null = null
  @Local hoveredAction: boolean = false

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.store.currentMapType === MapType.GRAPH ? '关系图工具' : '工具栏')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.store.getColor('navix_text_primary'))

        Blank()

        SymbolGlyph($r('sys.symbol.minus'))
          .fontSize(14)
          .fontColor([this.store.getColor('navix_icon_color')])
          .onClick(() => {
            this.store.toggleLeftPanel(LeftPanelState.TOOLS)
          })
      }
      .width('100%')
      .padding({ top: 10, left: 8, right: 8 })

      if (this.store.currentMapType === MapType.GRID) {
        this.ToolButton(ToolType.SELECT, '选择', '用于选择和查看网格节点')
        this.ToolButton(ToolType.START, '起点', '在网格上设置起点位置')
        this.ToolButton(ToolType.END, '终点', '在网格上设置终点位置')
        this.ToolButton(ToolType.OBSTACLE, '障碍', '在网格上添加障碍物')
        this.ToolButton(ToolType.ERASER, '橡皮', '擦除网格上的内容')

        Divider()
          .color(this.store.getColor('navix_border_color'))
          .margin({ left: 8, right: 8, top: 2, bottom: 2 })

        this.ToolButton(ToolType.RANDOM_OBSTACLE, '生成障碍', '随机生成障碍物')
        this.ToolButton(ToolType.RANDOM_STARTING, '生成起点', '在空白区域随机设置起点')
        this.ToolButton(ToolType.RANDOM_FINISHING, '生成终点', '在空白区域随机设置终点')
      } else if (this.store.currentMapType === MapType.GRAPH) {
        this.ToolButton(ToolType.SELECT, '浏览', '浏览画布与节点信息')
        this.ToolButton(ToolType.GRAPH_NODE, '节点', '在方格顶点添加节点')
        this.ToolButton(ToolType.GRAPH_ERASER, '删除', '删除顶点上的节点')

        Divider()
          .color(this.store.getColor('navix_border_color'))
          .margin({ left: 8, right: 8, top: 2, bottom: 2 })

        this.ActionButton('清空节点', '清空关系图中的所有节点', () => {
          this.store.clearGraphNodes()
        })
      } else {
        Text('该地图类型暂不支持工具编辑')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .padding({ left: 10, right: 10, top: 10 })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 6, right: 6, bottom: 10 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ActionButton(label: string, hint: string, action: () => void) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(13)
        .fontColor(this.store.getColor('navix_text_primary'))

      if (this.hoveredAction) {
        Text(hint)
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .lineHeight(14)
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .borderRadius(6)
    .backgroundColor(this.hoveredAction ? this.store.getColor('navix_border_color') : Color.Transparent)
    .onHover((isHover: boolean) => {
      this.hoveredAction = isHover
    })
    .onClick(() => {
      action()
    })
  }

  @Builder
  ToolButton(tool: ToolType, label: string, hint: string) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(13)
        .fontColor(this.store.getColor('navix_text_primary'))
        .fontWeight(this.store.currentTool === tool ? FontWeight.Medium : FontWeight.Normal)

      if (this.hoveredTool === tool) {
        Text(hint)
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .lineHeight(14)
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .borderRadius(6)
    .backgroundColor(this.store.currentTool === tool ? this.store.getColor('navix_button_active') : (this.hoveredTool === tool ? this.store.getColor('navix_border_color') : Color.Transparent))
    .onHover((isHover: boolean) => {
      this.hoveredTool = isHover ? tool : null
    })
    .onClick(() => {
      if (tool === ToolType.RANDOM_OBSTACLE) {
        this.store.generateRandomObstacles()
      } else if (tool === ToolType.RANDOM_STARTING) {
        this.store.generateRandomStarting()
      } else if (tool === ToolType.RANDOM_FINISHING) {
        this.store.generateRandomFinishing()
      } else if (tool === ToolType.GRAPH_NODE || tool === ToolType.GRAPH_ERASER) {
        this.store.setTool(tool)
      } else {
        this.store.setTool(tool)
      }
    })
  }
}
