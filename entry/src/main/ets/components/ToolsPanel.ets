import { NavixStore, navixStore } from '../store/NavixStore'
import { ToolType, LeftPanelState } from '../models/MapTypes'

@ComponentV2
export struct ToolsPanel {
  @Local store: NavixStore = navixStore
  @Local hoveredTool: ToolType | null = null

  build() {
    Column({ space: 8 }) {
      Row() {
        Text('工具栏')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.navix_text_primary'))

        Blank()

        SymbolGlyph($r('sys.symbol.minus'))
          .fontSize(14)
          .fontColor([$r('app.color.navix_icon_color')])
          .onClick(() => {
            this.store.toggleLeftPanel(LeftPanelState.TOOLS)
          })
      }
      .width('100%')
      .padding({ top: 10, left: 8, right: 8 })

      this.ToolButton(ToolType.SELECT, '选择', '用于选择和查看网格节点')
      this.ToolButton(ToolType.START, '起点', '在网格上设置起点位置')
      this.ToolButton(ToolType.END, '终点', '在网格上设置终点位置')
      this.ToolButton(ToolType.OBSTACLE, '障碍', '在网格上添加障碍物')
      this.ToolButton(ToolType.ERASER, '橡皮', '擦除网格上的内容')

      Divider()
        .color($r('app.color.navix_border_color'))
        .margin({ left: 8, right: 8, top: 2, bottom: 2 })

      this.ToolButton(ToolType.RANDOM, '随机生成', '随机生成障碍物')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 6, right: 6, bottom: 10 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ToolButton(tool: ToolType, label: string, hint: string) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(13)
        .fontColor(this.store.currentTool === tool ? '#333333' : $r('app.color.navix_text_primary'))
        .fontWeight(this.store.currentTool === tool ? FontWeight.Medium : FontWeight.Normal)

      if (this.hoveredTool === tool) {
        Text(hint)
          .fontSize(11)
          .fontColor($r('app.color.navix_text_secondary'))
          .lineHeight(14)
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .borderRadius(6)
    .backgroundColor(this.store.currentTool === tool ? '#DDDDDD' : (this.hoveredTool === tool ? '#EEEEEE' : Color.Transparent))
    .onHover((isHover: boolean) => {
      this.hoveredTool = isHover ? tool : null
    })
    .onClick(() => {
      if (tool === ToolType.RANDOM) {
        this.store.generateRandomObstacles()
      } else {
        this.store.setTool(tool)
      }
    })
  }
}
