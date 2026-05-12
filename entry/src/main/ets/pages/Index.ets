import { Colors, Sizes, FontSizes } from '../theme/Theme';

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
  @State playbackSpeed: number = 1;
  @State statusMessage: string = '就绪';
  @State nodesSearched: number = 0;
  @State pathLength: number = 0;
  @State executionTime: number = 0;
  @State sidebarCollapsed: boolean = false;

  build() {
    Column() {
      this.buildTitleBar()
      Row() {
        this.buildSidebar()
        Column() {
          this.buildMainCanvas()
          this.buildTimeline()
        }
        .layoutWeight(1)
        this.buildParamPanel()
      }
      .layoutWeight(1)
      this.buildStatusBar()
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
          .borderRadius(Sizes.borderRadius)
          .onClick(() => {
            this.isPlaying = !this.isPlaying;
            this.statusMessage = this.isPlaying ? '运行中...' : '已暂停';
          })

        Button('↺')
          .width(Sizes.buttonSize)
          .height(Sizes.buttonSize)
          .fontSize(14)
          .backgroundColor(Colors.buttonBackground)
          .borderRadius(Sizes.borderRadius)
          .onClick(() => {
            this.resetAlgorithm();
          })
      }
      .margin({ right: Sizes.padding })
    }
    .width('100%')
    .height(Sizes.toolbarHeight)
    .backgroundColor(Colors.panelBackground)
    .border({
      width: { bottom: 1 },
      color: Colors.border
    })
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

        this.buildToolButton('pointer', '✦', '选择')
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
        this.buildAlgorithmButton('Dijkstra', 'Dij', 'Dijkstra最短路径')
        this.buildAlgorithmButton('BFS', 'BFS', '广度优先搜索')
        this.buildAlgorithmButton('DFS', 'DFS', '深度优先搜索')
        this.buildAlgorithmButton('JPS', 'JPS', '跳点搜索')
      }
      .padding(Sizes.padding)
      .width('100%')
      .margin({ top: Sizes.margin })
    }
    .width(this.sidebarCollapsed ? Sizes.sidebarCollapsedWidth : Sizes.sidebarWidth)
    .height('100%')
    .backgroundColor(Colors.panelBackground)
    .border({
      width: { right: 1 },
      color: Colors.border
    })
    .transition(TransitionEffect.OPACITY.animation({ duration: Animations.normal }))
  }

  @Builder
  buildToolButton(id: string, icon: string, label: string) {
    Button() {
      Row() {
        Text(icon)
          .fontSize(Sizes.iconSize)
          .fontColor(this.selectedTool === id ? Colors.active : Colors.textPrimary)
        if (!this.sidebarCollapsed) {
          Text(label)
            .fontSize(FontSizes.medium)
            .fontColor(this.selectedTool === id ? Colors.active : Colors.textPrimary)
            .margin({ left: Sizes.margin })
        }
      }
      .width('100%')
      .padding(Sizes.padding)
    }
    .width('100%')
    .backgroundColor(this.selectedTool === id ? Colors.selected : 'transparent')
    .borderRadius(Sizes.borderRadius)
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
        if (!this.sidebarCollapsed) {
          Text(fullLabel)
            .fontSize(FontSizes.small)
            .fontColor(Colors.textSecondary)
        }
      }
      .width('100%')
      .padding(Sizes.padding)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(this.selectedAlgorithm === id ? Colors.selected : 'transparent')
    .borderRadius(Sizes.borderRadius)
    .onClick(() => {
      this.selectedAlgorithm = id;
    })
  }

  @Builder
  buildMainCanvas() {
    Column() {
      Stack() {
        Canvas(new NavixCanvasRenderer())
          .width('100%')
          .height('100%')
          .backgroundColor(Colors.background)
          .onReady(() => {
          })
      }
      .width('100%')
      .layoutWeight(1)
      .border({
        width: 1,
        color: Colors.border,
        radius: Sizes.borderRadius
      })
      .margin(Sizes.padding)

      Row() {
        Text(`网格: ${this.gridRows} × ${this.gridCols}`)
          .fontSize(FontSizes.small)
          .fontColor(Colors.textSecondary)
        Blank()
        Row() {
          Text('起点')
            .fontSize(FontSizes.small)
            .fontColor(Colors.textSecondary)
          Circle()
            .size({ width: 12, height: 12 })
            .fill(Colors.start)
            .margin({ left: 4 })
          Text('终点')
            .fontSize(FontSizes.small)
            .fontColor(Colors.textSecondary)
            .margin({ left: 12 })
          Circle()
            .size({ width: 12, height: 12 })
            .fill(Colors.end)
            .margin({ left: 4 })
          Text('障碍')
            .fontSize(FontSizes.small)
            .fontColor(Colors.textSecondary)
            .margin({ left: 12 })
          Rect()
            .size({ width: 12, height: 12 })
            .fill(Colors.obstacle)
            .margin({ left: 4 })
        }
      }
      .padding({ left: Sizes.padding, right: Sizes.padding, bottom: Sizes.margin })
    }
    .layoutWeight(1)
  }

  @Builder
  buildParamPanel() {
    Column() {
      Column() {
        Text('参数设置')
          .fontSize(FontSizes.medium)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)
          .width('100%')
          .padding(Sizes.padding)
      }
      .width('100%')
      .backgroundColor(Colors.panelBackground)
      .border({
        width: { bottom: 1 },
        color: Colors.border
      })

      Scroll() {
        Column() {
          this.buildParamSection('地图设置', [
            this.buildSliderParam('行数', this.gridRows, 5, 50, (val) => {
              this.gridRows = val;
            }),
            this.buildSliderParam('列数', this.gridCols, 5, 50, (val) => {
              this.gridCols = val;
            })
          ])

          Divider().color(Colors.border).margin({ vertical: Sizes.padding })

          this.buildParamSection('启发函数', [
            this.buildSelectParam('类型', ['曼哈顿', '欧几里得', '对角线'])
          ])

          Divider().color(Colors.border).margin({ vertical: Sizes.padding })

          this.buildParamSection('显示选项', [
            this.buildToggleParam('显示OPEN集', true),
            this.buildToggleParam('显示CLOSED集', true),
            this.buildToggleParam('显示热力图', false)
          ])

          Divider().color(Colors.border).margin({ vertical: Sizes.padding })

          this.buildParamSection('操作', [
            this.buildActionButton('清空地图', () => {
              this.statusMessage = '地图已清空';
            }),
            this.buildActionButton('随机生成', () => {
              this.statusMessage = '随机地图已生成';
            }),
            this.buildActionButton('导出地图', () => {
              this.statusMessage = '地图已导出';
            })
          ])
        }
        .padding(Sizes.padding)
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width(Sizes.paramPanelWidth)
    .height('100%')
    .backgroundColor(Colors.panelBackground)
    .border({
      width: { left: 1 },
      color: Colors.border
    })
  }

  @Builder
  buildParamSection(title: string, content: BuilderContent[]) {
    Column() {
      Text(title)
        .fontSize(FontSizes.small)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.textSecondary)
        .width('100%')
        .margin({ bottom: Sizes.margin })

      ForEach(content, (builder: Function) => {
        builder.call(this);
      })
    }
    .width('100%')
  }

  @Builder
  buildSliderParam(label: string, value: number, min: number, max: number, onChange: (val: number) => void) {
    Column() {
      Row() {
        Text(label)
          .fontSize(FontSizes.medium)
          .fontColor(Colors.textPrimary)
        Blank()
        Text(value.toString())
          .fontSize(FontSizes.medium)
          .fontColor(Colors.active)
      }
      .width('100%')
      .margin({ bottom: Sizes.margin })

      Slider({ value: value, min: min, max: max, step: 1 })
        .blockColor(Colors.active)
        .trackColor(Colors.sliderTrack)
        .selectedColor(Colors.sliderSelected)
        .onChange((val: number) => {
          onChange(val);
        })
    }
    .width('100%')
    .margin({ bottom: Sizes.margin })
  }

  @Builder
  buildSelectParam(label: string, options: string[]) {
    Column() {
      Text(label)
        .fontSize(FontSizes.medium)
        .fontColor(Colors.textPrimary)
        .width('100%')
        .margin({ bottom: Sizes.margin })

      ForEach(options, (option: string, index: number) => {
        Row() {
          Radio({ value: option, group: label })
            .radioStyle({ checkedBackgroundColor: Colors.active })
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.statusMessage = `已选择: ${option}`;
              }
            })
          Text(option)
            .fontSize(FontSizes.medium)
            .fontColor(Colors.textPrimary)
            .margin({ left: Sizes.margin })
        }
        .width('100%')
        .margin({ bottom: Sizes.margin })
      })
    }
    .width('100%')
    .margin({ bottom: Sizes.margin })
  }

  @Builder
  buildToggleParam(label: string, defaultValue: boolean) {
    Row() {
      Text(label)
        .fontSize(FontSizes.medium)
        .fontColor(Colors.textPrimary)
      Blank()
      Toggle({ type: ToggleType.Switch, isOn: defaultValue })
        .selectedColor(Colors.active)
        .onChange((isOn: boolean) => {
          this.statusMessage = `${label}: ${isOn ? '开启' : '关闭'}`;
        })
    }
    .width('100%')
    .margin({ bottom: Sizes.margin })
  }

  @Builder
  buildActionButton(label: string, onClick: () => void) {
    Button(label)
      .width('100%')
      .height(36)
      .fontSize(FontSizes.medium)
      .fontColor(Colors.textPrimary)
      .backgroundColor(Colors.buttonBackground)
      .borderRadius(Sizes.borderRadius)
      .margin({ bottom: Sizes.margin })
      .onClick(onClick)
  }

  @Builder
  buildTimeline() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          Button('⏮')
            .width(32)
            .height(32)
            .fontSize(14)
            .backgroundColor(Colors.buttonBackground)
            .borderRadius(Sizes.borderRadius)
            .onClick(() => {
              this.currentStep = 0;
            })

          Button('◀')
            .width(32)
            .height(32)
            .fontSize(14)
            .backgroundColor(Colors.buttonBackground)
            .borderRadius(Sizes.borderRadius)
            .onClick(() => {
              if (this.currentStep > 0) this.currentStep--;
            })

          Button(this.isPlaying ? '⏸' : '▶')
            .width(40)
            .height(32)
            .fontSize(16)
            .backgroundColor(Colors.active)
            .borderRadius(Sizes.borderRadius)
            .onClick(() => {
              this.isPlaying = !this.isPlaying;
            })

          Button('▶')
            .width(32)
            .height(32)
            .fontSize(14)
            .backgroundColor(Colors.buttonBackground)
            .borderRadius(Sizes.borderRadius)
            .onClick(() => {
              if (this.currentStep < this.totalSteps) this.currentStep++;
            })

          Button('⏭')
            .width(32)
            .height(32)
            .fontSize(14)
            .backgroundColor(Colors.buttonBackground)
            .borderRadius(Sizes.borderRadius)
            .onClick(() => {
              this.currentStep = this.totalSteps;
            })
        }

        Blank()

        Text(`步骤: ${this.currentStep} / ${this.totalSteps}`)
          .fontSize(FontSizes.medium)
          .fontColor(Colors.textPrimary)
          .margin({ right: Sizes.padding })
      }
      .width('100%')
      .padding(Sizes.padding)

      Row() {
        Slider({
          value: this.currentStep,
          min: 0,
          max: this.totalSteps > 0 ? this.totalSteps : 1,
          step: 1
        })
          .blockColor(Colors.active)
          .trackColor(Colors.sliderTrack)
          .selectedColor(Colors.sliderSelected)
          .onChange((val: number) => {
            this.currentStep = Math.floor(val);
          })
      }
      .width('100%')
      .padding({ left: Sizes.padding, right: Sizes.padding, bottom: Sizes.padding })
    }
    .width('100%')
    .backgroundColor(Colors.panelBackground)
    .border({
      width: { top: 1 },
      color: Colors.border
    })
  }

  @Builder
  buildStatusBar() {
    Row() {
      Row({ space: 8 }) {
        Circle()
          .size({ width: 8, height: 8 })
          .fill(this.isPlaying ? Colors.success : Colors.textSecondary)
        Text(this.statusMessage)
          .fontSize(FontSizes.small)
          .fontColor(Colors.textPrimary)
      }
      .margin({ left: Sizes.padding })

      Blank()

      Row({ space: 16 }) {
        Text(`搜索节点: ${this.nodesSearched}`)
          .fontSize(FontSizes.small)
          .fontColor(Colors.textSecondary)

        Divider()
          .vertical(true)
          .height(14)
          .color(Colors.border)

        Text(`路径长度: ${this.pathLength}`)
          .fontSize(FontSizes.small)
          .fontColor(Colors.textSecondary)

        Divider()
          .vertical(true)
          .height(14)
          .color(Colors.border)

        Text(`时间: ${this.executionTime.toFixed(2)}ms`)
          .fontSize(FontSizes.small)
          .fontColor(Colors.textSecondary)
      }
      .margin({ right: Sizes.padding })
    }
    .width('100%')
    .height(Sizes.statusBarHeight)
    .backgroundColor(Colors.active)
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

class NavixCanvasRenderer extends CanvasRenderingContext2D {
  constructor() {
    super();
  }
}

export default NavixApp;
