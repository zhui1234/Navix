export interface HeatPoint {
  x: number;
  y: number;
  intensity: number;
}

export default class HeatLayer {
  private visible: boolean = true;
  private points: HeatPoint[] = [];
  private radius: number = 30;
  private gradient: CanvasGradient | null = null;

  setPoints(points: HeatPoint[]): void {
    this.points = points;
  }

  addPoint(point: HeatPoint): void {
    this.points.push(point);
  }

  setRadius(radius: number): void {
    this.radius = radius;
  }

  render(ctx: CanvasRenderingContext2D): void {
    if (!this.points.length) return;

    this.points.forEach(point => {
      this.drawHeatPoint(ctx, point);
    });
  }

  private drawHeatPoint(ctx: CanvasRenderingContext2D, point: HeatPoint): void {
    const gradient = ctx.createRadialGradient(
      point.x, point.y, 0,
      point.x, point.y, this.radius
    );

    gradient.addColorStop(0, `rgba(255, 0, 0, ${point.intensity})`);
    gradient.addColorStop(0.5, `rgba(255, 255, 0, ${point.intensity * 0.5})`);
    gradient.addColorStop(1, 'rgba(255, 255, 255, 0)');

    ctx.fillStyle = gradient;
    ctx.beginPath();
    ctx.arc(point.x, point.y, this.radius, 0, Math.PI * 2);
    ctx.fill();
  }

  isVisible(): boolean {
    return this.visible;
  }

  setVisible(visible: boolean): void {
    this.visible = visible;
  }

  clear(): void {
    this.points = [];
  }

  invalidate(x: number, y: number, width: number, height: number): void {
  }
}
