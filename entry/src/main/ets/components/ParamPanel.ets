@Component
export struct ParamPanel {
  @State algorithmType: string = 'AStar';
  @State heuristicType: string = 'Manhattan';
  @State animationSpeed: number = 1;

  build() {
    Column() {
      Text('算法选择')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
      Select([
        { value: 'A*', symbol: 'AStar' },
        { value: 'Dijkstra', symbol: 'Dijkstra' },
        { value: 'BFS', symbol: 'BFS' },
        { value: 'DFS', symbol: 'DFS' },
        { value: 'JPS', symbol: 'JPS' }
      ])
        .selected(this.algorithmType)
        .onSelect((index: number, symbol: string) => {
          this.algorithmType = symbol;
        })

      Text('启发函数')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })
      Select([
        { value: '曼哈顿距离', symbol: 'Manhattan' },
        { value: '欧几里得距离', symbol: 'Euclidean' },
        { value: '对角距离', symbol: 'Diagonal' }
      ])
        .selected(this.heuristicType)
        .onSelect((index: number, symbol: string) => {
          this.heuristicType = symbol;
        })

      Text('动画速度: ' + this.animationSpeed + 'x')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })
      Slider({ value: this.animationSpeed, min: 0.5, max: 5, step: 0.5 })
        .onChange((value: number) => {
          this.animationSpeed = value;
        })
    }
    .width('100%')
    .padding(10)
    .alignItems(HorizontalAlign.Start)
  }
}
