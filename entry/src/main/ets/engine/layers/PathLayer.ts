export interface PathPoint {
  x: number;
  y: number;
}

export default class PathLayer {
  private visible: boolean = true;
  private path: PathPoint[] = [];
  private lineWidth: number = 3;
  private strokeStyle: string = '#2196F3';

  setPath(path: PathPoint[]): void {
    this.path = path;
  }

  setLineWidth(width: number): void {
    this.lineWidth = width;
  }

  setStrokeStyle(style: string): void {
    this.strokeStyle = style;
  }

  render(ctx: CanvasRenderingContext2D): void {
    if (this.path.length < 2) return;

    ctx.strokeStyle = this.strokeStyle;
    ctx.lineWidth = this.lineWidth;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';

    ctx.beginPath();
    ctx.moveTo(this.path[0].x, this.path[0].y);

    for (let i = 1; i < this.path.length; i++) {
      ctx.lineTo(this.path[i].x, this.path[i].y);
    }

    ctx.stroke();
  }

  isVisible(): boolean {
    return this.visible;
  }

  setVisible(visible: boolean): void {
    this.visible = visible;
  }

  clear(): void {
    this.path = [];
  }

  invalidate(x: number, y: number, width: number, height: number): void {
  }
}
