import { Colors, Sizes, FontSizes } from '../theme/Theme';

@Component
export struct TimelineBar {
  @State currentStep: number = 0;
  @State totalSteps: number = 0;
  @State isPlaying: boolean = false;
  @State playbackSpeed: number = 1;

  build() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          Button('⏮')
            .width(32)
            .height(32)
            .fontSize(14)
            .backgroundColor(Colors.buttonBackground)
            .borderRadius({ radius: Sizes.borderRadius })
            .onClick(() => {
              this.currentStep = 0;
            })

          Button('◀')
            .width(32)
            .height(32)
            .fontSize(14)
            .backgroundColor(Colors.buttonBackground)
            .borderRadius({ radius: Sizes.borderRadius })
            .onClick(() => {
              if (this.currentStep > 0) {
                this.currentStep--;
              }
            })

          Button(this.isPlaying ? '⏸' : '▶')
            .width(40)
            .height(32)
            .fontSize(16)
            .backgroundColor(Colors.active)
            .borderRadius({ radius: Sizes.borderRadius })
            .onClick(() => {
              this.isPlaying = !this.isPlaying;
            })

          Button('▶')
            .width(32)
            .height(32)
            .fontSize(14)
            .backgroundColor(Colors.buttonBackground)
            .borderRadius({ radius: Sizes.borderRadius })
            .onClick(() => {
              if (this.currentStep < this.totalSteps) {
                this.currentStep++;
              }
            })

          Button('⏭')
            .width(32)
            .height(32)
            .fontSize(14)
            .backgroundColor(Colors.buttonBackground)
            .borderRadius({ radius: Sizes.borderRadius })
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
    .border({ width: { top: 1 }, color: Colors.border })
  }
}
