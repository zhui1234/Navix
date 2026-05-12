import { Colors, Sizes } from '../theme/Theme';

@Component
export struct CanvasView {
  @State private gridData: number[][] = [];

  aboutToAppear() {
    this.initializeGrid(20, 20);
  }

  private initializeGrid(rows: number, cols: number) {
    this.gridData = [];
    for (let i = 0; i < rows; i++) {
      let row: number[] = [];
      for (let j = 0; j < cols; j++) {
        row.push(0);
      }
      this.gridData.push(row);
    }
  }

  build() {
    Stack() {
      Canvas()
        .width('100%')
        .height('100%')
        .backgroundColor(Colors.background)
    }
    .width('100%')
    .height('100%')
    .border({ width: 1, color: Colors.border, radius: { radius: Sizes.borderRadius } })
    .margin(Sizes.padding)
  }
}
