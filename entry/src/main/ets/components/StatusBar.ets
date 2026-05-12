@Component
export struct StatusBar {
  @State nodesSearched: number = 0;
  @State pathLength: number = 0;
  @State executionTime: number = 0;
  @State currentStatus: string = '就绪';

  build() {
    Row() {
      Column() {
        Text('状态')
          .fontSize(12)
          .fontColor('#888888')
        Text(this.currentStatus)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
      }

      Divider()
        .vertical(true)
        .height(30)

      Column() {
        Text('搜索节点')
          .fontSize(12)
          .fontColor('#888888')
        Text(this.nodesSearched.toString())
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
      }

      Divider()
        .vertical(true)
        .height(30)

      Column() {
        Text('路径长度')
          .fontSize(12)
          .fontColor('#888888')
        Text(this.pathLength.toString())
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
      }

      Divider()
        .vertical(true)
        .height(30)

      Column() {
        Text('执行时间')
          .fontSize(12)
          .fontColor('#888888')
        Text(this.executionTime.toFixed(2) + 'ms')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
      }
    }
    .width('100%')
    .height(60)
    .padding(10)
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor('#F5F5F5')
  }
}
