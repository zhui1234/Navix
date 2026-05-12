export interface CellData {
  x: number;
  y: number;
  type: CellType;
  terrainCost: number;
  gScore?: number;
  fScore?: number;
}

export enum CellType {
  EMPTY = 0,
  OBSTACLE = 1,
  START = 2,
  END = 3,
  VISITED = 4,
  IN_PATH = 5,
  IN_OPEN = 6
}

export default class GridLayer {
  private visible: boolean = true;
  private cellSize: number = 20;
  private gridData: CellData[][] = [];
  private invalidRegion: { x: number; y: number; width: number; height: number } | null = null;

  setCellSize(size: number): void {
    this.cellSize = size;
  }

  setGridData(data: CellData[][]): void {
    this.gridData = data;
  }

  render(ctx: CanvasRenderingContext2D): void {
    if (!this.gridData.length) return;

    const rows = this.gridData.length;
    const cols = this.gridData[0].length;

    for (let i = 0; i < rows; i++) {
      for (let j = 0; j < cols; j++) {
        const cell = this.gridData[i][j];
        this.drawCell(ctx, cell);
      }
    }

    this.drawGridLines(ctx, rows, cols);
  }

  private drawCell(ctx: CanvasRenderingContext2D, cell: CellData): void {
    const x = cell.x * this.cellSize;
    const y = cell.y * this.cellSize;

    switch (cell.type) {
      case CellType.EMPTY:
        ctx.fillStyle = '#FFFFFF';
        break;
      case CellType.OBSTACLE:
        ctx.fillStyle = '#333333';
        break;
      case CellType.START:
        ctx.fillStyle = '#4CAF50';
        break;
      case CellType.END:
        ctx.fillStyle = '#F44336';
        break;
      case CellType.VISITED:
        ctx.fillStyle = '#BBDEFB';
        break;
      case CellType.IN_PATH:
        ctx.fillStyle = '#FFEB3B';
        break;
      case CellType.IN_OPEN:
        ctx.fillStyle = '#C8E6C9';
        break;
      default:
        ctx.fillStyle = '#FFFFFF';
    }

    ctx.fillRect(x, y, this.cellSize, this.cellSize);
  }

  private drawGridLines(ctx: CanvasRenderingContext2D, rows: number, cols: number): void {
    ctx.strokeStyle = '#E0E0E0';
    ctx.lineWidth = 1;

    for (let i = 0; i <= rows; i++) {
      ctx.beginPath();
      ctx.moveTo(0, i * this.cellSize);
      ctx.lineTo(cols * this.cellSize, i * this.cellSize);
      ctx.stroke();
    }

    for (let j = 0; j <= cols; j++) {
      ctx.beginPath();
      ctx.moveTo(j * this.cellSize, 0);
      ctx.lineTo(j * this.cellSize, rows * this.cellSize);
      ctx.stroke();
    }
  }

  isVisible(): boolean {
    return this.visible;
  }

  setVisible(visible: boolean): void {
    this.visible = visible;
  }

  invalidate(x: number, y: number, width: number, height: number): void {
    this.invalidRegion = { x, y, width, height };
  }
}
