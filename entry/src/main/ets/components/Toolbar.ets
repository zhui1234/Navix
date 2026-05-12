@Component
export struct Toolbar {
  @State selectedTool: string = 'select';
  @State isPlaying: boolean = false;

  build() {
    Row() {
      Button('选择')
        .onClick(() => this.selectedTool = 'select')
      Button('障碍')
        .onClick(() => this.selectedTool = 'obstacle')
      Button('起点')
        .onClick(() => this.selectedTool = 'start')
      Button('终点')
        .onClick(() => this.selectedTool = 'end')
      Button(this.isPlaying ? '暂停' : '运行')
        .onClick(() => this.isPlaying = !this.isPlaying)
    }
    .width('100%')
    .height(50)
    .padding(10)
    .justifyContent(FlexAlign.SpaceEvenly)
  }
}
