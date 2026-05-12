@Component
export struct CanvasView {
  @State private gridData: number[][] = [];
  @State private cellSize: number = 20;

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
      Canvas(new CanvasRenderer())
        .width('100%')
        .height('100%')
        .onReady(() => {
        })
    }
    .width('100%')
    .height('100%')
  }
}

class CanvasRenderer extends CanvasRenderingContext2D {
}
