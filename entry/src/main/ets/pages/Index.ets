import { Colors, Sizes, FontSizes } from '../theme/Theme';
import { Toolbar } from '../components/Toolbar';
import { CanvasView } from '../components/CanvasView';
import { ParamPanel } from '../components/ParamPanel';
import { TimelineBar } from '../components/TimelineBar';
import { StatusBar } from '../components/StatusBar';

@Entry
@Component
struct NavixApp {
  @State selectedTool: string = 'select';
  @State selectedAlgorithm: string = 'AStar';
  @State gridRows: number = 20;
  @State gridCols: number = 20;
  @State isPlaying: boolean = false;
  @State currentStep: number = 0;
  @State totalSteps: number = 0;
  @State statusMessage: string = '就绪';
  @State nodesSearched: number = 0;
  @State pathLength: number = 0;
  @State executionTime: number = 0;

  build() {
    Column() {
      this.buildTitleBar()
      Row() {
        this.buildSidebar()
        Column() {
          CanvasView()
            .layoutWeight(1)
          TimelineBar()
        }
        .layoutWeight(1)
        ParamPanel()
      }
      .layoutWeight(1)
      StatusBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
  }

  @Builder
  buildTitleBar() {
    Row() {
      Row() {
        Text('⬢')
          .fontSize(20)
          .fontColor(Colors.active)
        Text(' Navix')
          .fontSize(FontSizes.title)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)
      }
      .margin({ left: Sizes.padding })

      Blank()

      Row({ space: 4 }) {
        Button('▶')
          .width(Sizes.buttonSize)
          .height(Sizes.buttonSize)
          .fontSize(14)
          .backgroundColor(Colors.buttonBackground)
          .borderRadius({ radius: Sizes.borderRadius })
          .onClick(() => {
            this.isPlaying = !this.isPlaying;
            this.statusMessage = this.isPlaying ? '运行中...' : '已暂停';
          })

        Button('↺')
          .width(Sizes.buttonSize)
          .height(Sizes.buttonSize)
          .fontSize(14)
          .backgroundColor(Colors.buttonBackground)
          .borderRadius({ radius: Sizes.borderRadius })
          .onClick(() => {
            this.resetAlgorithm();
          })
      }
      .margin({ right: Sizes.padding })
    }
    .width('100%')
    .height(Sizes.toolbarHeight)
    .backgroundColor(Colors.panelBackground)
    .border({ width: { bottom: 1 }, color: Colors.border })
  }

  @Builder
  buildSidebar() {
    Column() {
      Column() {
        Text('工具')
          .fontSize(FontSizes.small)
          .fontColor(Colors.textSecondary)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding({ left: Sizes.padding, bottom: Sizes.margin })

        this.buildToolButton('select', '✦', '选择')
        this.buildToolButton('obstacle', '▪', '障碍物')
        this.buildToolButton('start', '◉', '起点')
        this.buildToolButton('end', '◎', '终点')
        this.buildToolButton('eraser', '⌫', '橡皮擦')
      }
      .padding(Sizes.padding)
      .width('100%')

      Divider()
        .color(Colors.border)

      Column() {
        Text('算法')
          .fontSize(FontSizes.small)
          .fontColor(Colors.textSecondary)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding({ left: Sizes.padding, bottom: Sizes.margin })

        this.buildAlgorithmButton('AStar', 'A*', 'A*寻路算法')
        this.buildAlgorithmButton('Dijkstra', 'Dijk', 'Dijkstra最短路径')
        this.buildAlgorithmButton('BFS', 'BFS', '广度优先搜索')
        this.buildAlgorithmButton('DFS', 'DFS', '深度优先搜索')
        this.buildAlgorithmButton('JPS', 'JPS', '跳点搜索')
      }
      .padding(Sizes.padding)
      .width('100%')
      .margin({ top: Sizes.margin })
    }
    .width(Sizes.sidebarWidth)
    .height('100%')
    .backgroundColor(Colors.panelBackground)
    .border({ width: { right: 1 }, color: Colors.border })
  }

  @Builder
  buildToolButton(id: string, icon: string, label: string) {
    Button() {
      Row() {
        Text(icon)
          .fontSize(Sizes.iconSize)
          .fontColor(this.selectedTool === id ? Colors.active : Colors.textPrimary)
        Text(label)
          .fontSize(FontSizes.medium)
          .fontColor(this.selectedTool === id ? Colors.active : Colors.textPrimary)
          .margin({ left: Sizes.margin })
      }
      .width('100%')
      .padding(Sizes.padding)
    }
    .width('100%')
    .backgroundColor(this.selectedTool === id ? Colors.selected : 'transparent')
    .borderRadius({ radius: Sizes.borderRadius })
    .onClick(() => {
      this.selectedTool = id;
    })
  }

  @Builder
  buildAlgorithmButton(id: string, shortLabel: string, fullLabel: string) {
    Button() {
      Column() {
        Text(shortLabel)
          .fontSize(FontSizes.medium)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.selectedAlgorithm === id ? Colors.active : Colors.textPrimary)
        Text(fullLabel)
          .fontSize(FontSizes.small)
          .fontColor(Colors.textSecondary)
      }
      .width('100%')
      .padding(Sizes.padding)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(this.selectedAlgorithm === id ? Colors.selected : 'transparent')
    .borderRadius({ radius: Sizes.borderRadius })
    .onClick(() => {
      this.selectedAlgorithm = id;
    })
  }

  resetAlgorithm() {
    this.currentStep = 0;
    this.totalSteps = 0;
    this.nodesSearched = 0;
    this.pathLength = 0;
    this.executionTime = 0;
    this.isPlaying = false;
    this.statusMessage = '已重置';
  }
}
