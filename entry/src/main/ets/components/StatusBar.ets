import { Colors, Sizes, FontSizes } from '../theme/Theme';

@Component
export struct StatusBar {
  @State nodesSearched: number = 0;
  @State pathLength: number = 0;
  @State executionTime: number = 0;
  @State currentStatus: string = '就绪';

  build() {
    Row() {
      Row({ space: 8 }) {
        Circle()
          .size({ width: 8, height: 8 })
          .fill(Colors.success)
        Text(this.currentStatus)
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
}
