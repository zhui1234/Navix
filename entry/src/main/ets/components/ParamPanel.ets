import { Colors, Sizes, FontSizes } from '../theme/Theme';

@Component
export struct ParamPanel {
  @State selectedHeuristic: string = 'Manhattan';

  build() {
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
      .border({ width: { bottom: 1 }, color: Colors.border })

      Scroll() {
        Column() {
          this.buildParamSection('地图设置')
          this.buildSliderParam('行数', 20, 5, 50)
          this.buildSliderParam('列数', 20, 5, 50)

          Divider().color(Colors.border).margin({ vertical: Sizes.padding })

          this.buildParamSection('启发函数')
          this.buildRadioOption('Manhattan', '曼哈顿距离')
          this.buildRadioOption('Euclidean', '欧几里得距离')
          this.buildRadioOption('Diagonal', '对角距离')

          Divider().color(Colors.border).margin({ vertical: Sizes.padding })

          this.buildParamSection('显示选项')
          this.buildToggleOption('显示OPEN集', true)
          this.buildToggleOption('显示CLOSED集', true)
          this.buildToggleOption('显示热力图', false)

          Divider().color(Colors.border).margin({ vertical: Sizes.padding })

          this.buildParamSection('操作')
          this.buildActionButton('清空地图')
          this.buildActionButton('随机生成')
          this.buildActionButton('导出地图')
        }
        .padding(Sizes.padding)
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width(Sizes.paramPanelWidth)
    .height('100%')
    .backgroundColor(Colors.panelBackground)
    .border({ width: { left: 1 }, color: Colors.border })
  }

  @Builder
  buildParamSection(title: string) {
    Text(title)
      .fontSize(FontSizes.small)
      .fontWeight(FontWeight.Bold)
      .fontColor(Colors.textSecondary)
      .width('100%')
      .margin({ bottom: Sizes.margin })
  }

  @Builder
  buildSliderParam(label: string, value: number, min: number, max: number) {
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
    }
    .width('100%')
    .margin({ bottom: Sizes.margin })
  }

  @Builder
  buildRadioOption(id: string, label: string) {
    Row() {
      Radio({ value: id, group: 'heuristic' })
        .radioStyle({ checkedBackgroundColor: Colors.active })
        .onChange((isChecked: boolean) => {
          if (isChecked) {
            this.selectedHeuristic = id;
          }
        })
      Text(label)
        .fontSize(FontSizes.medium)
        .fontColor(Colors.textPrimary)
        .margin({ left: Sizes.margin })
    }
    .width('100%')
    .margin({ bottom: Sizes.margin })
  }

  @Builder
  buildToggleOption(label: string, defaultValue: boolean) {
    Row() {
      Text(label)
        .fontSize(FontSizes.medium)
        .fontColor(Colors.textPrimary)
      Blank()
      Toggle({ type: ToggleType.Switch, isOn: defaultValue })
        .selectedColor(Colors.active)
    }
    .width('100%')
    .margin({ bottom: Sizes.margin })
  }

  @Builder
  buildActionButton(label: string) {
    Button(label)
      .width('100%')
      .height(36)
      .fontSize(FontSizes.medium)
      .fontColor(Colors.textPrimary)
      .backgroundColor(Colors.buttonBackground)
      .borderRadius({ radius: Sizes.borderRadius })
      .margin({ bottom: Sizes.margin })
  }
}
