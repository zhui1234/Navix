@Component
export struct TimelineBar {
  @State currentStep: number = 0;
  @State totalSteps: number = 0;
  @State isPlaying: boolean = false;
  @State playbackSpeed: number = 1;

  build() {
    Column() {
      Row() {
        Text('步骤: ' + this.currentStep + ' / ' + this.totalSteps)
          .fontSize(14)
          .margin({ right: 10 })

        Slider({
          value: this.currentStep,
          min: 0,
          max: this.totalSteps > 0 ? this.totalSteps : 1
        })
          .onChange((value: number) => {
            this.currentStep = Math.floor(value);
          })
      }
      .width('100%')

      Row() {
        Button('<<')
          .onClick(() => {
            this.currentStep = 0;
          })

        Button(this.isPlaying ? '暂停' : '播放')
          .onClick(() => {
            this.isPlaying = !this.isPlaying;
          })

        Button('>>')
          .onClick(() => {
            if (this.currentStep < this.totalSteps) {
              this.currentStep++;
            }
          })

        Button('单步')
          .onClick(() => {
            if (this.currentStep < this.totalSteps) {
              this.currentStep++;
            }
          })

        Select([
          { value: '0.5x', symbol: '0.5' },
          { value: '1x', symbol: '1' },
          { value: '2x', symbol: '2' },
          { value: '4x', symbol: '4' }
        ])
          .selected('1')
          .onSelect((index: number, symbol: string) => {
            this.playbackSpeed = parseFloat(symbol);
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ top: 10 })
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#EEEEEE')
  }
}
