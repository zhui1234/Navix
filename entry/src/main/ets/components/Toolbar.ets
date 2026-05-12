import { Colors, Sizes, FontSizes } from '../theme/Theme';

@Component
export struct Toolbar {
  @State selectedTool: string = 'select';
  @State isPlaying: boolean = false;

  build() {
    Row() {
      Button('Select')
        .onClick(() => this.selectedTool = 'select')
        .backgroundColor(this.selectedTool === 'select' ? Colors.active : Colors.buttonBackground)
        .borderRadius({ radius: Sizes.borderRadius })
      Button('Obstacle')
        .onClick(() => this.selectedTool = 'obstacle')
        .backgroundColor(this.selectedTool === 'obstacle' ? Colors.active : Colors.buttonBackground)
        .borderRadius({ radius: Sizes.borderRadius })
      Button('Start')
        .onClick(() => this.selectedTool = 'start')
        .backgroundColor(this.selectedTool === 'start' ? Colors.active : Colors.buttonBackground)
        .borderRadius({ radius: Sizes.borderRadius })
      Button('End')
        .onClick(() => this.selectedTool = 'end')
        .backgroundColor(this.selectedTool === 'end' ? Colors.active : Colors.buttonBackground)
        .borderRadius({ radius: Sizes.borderRadius })
      Button(this.isPlaying ? 'Pause' : 'Run')
        .onClick(() => this.isPlaying = !this.isPlaying)
        .backgroundColor(this.isPlaying ? Colors.success : Colors.buttonBackground)
        .borderRadius({ radius: Sizes.borderRadius })
    }
    .width('100%')
    .height(Sizes.toolbarHeight)
    .padding(Sizes.padding)
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor(Colors.panelBackground)
    .border({ width: { bottom: 1 }, color: Colors.border })
  }
}
