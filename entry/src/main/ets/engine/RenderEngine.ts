import RenderLayer from './layers/GridLayer';

export class RenderEngine {
  private layers: RenderLayer[] = [];
  private canvas: CanvasRenderingContext2D | null = null;

  addLayer(layer: RenderLayer): void {
    this.layers.push(layer);
  }

  removeLayer(layer: RenderLayer): void {
    const index = this.layers.indexOf(layer);
    if (index > -1) {
      this.layers.splice(index, 1);
    }
  }

  setCanvas(ctx: CanvasRenderingContext2D): void {
    this.canvas = ctx;
  }

  render(): void {
    if (!this.canvas) return;

    this.canvas.clearRect(0, 0, this.canvas.width, this.canvas.height);

    this.layers.forEach(layer => {
      if (layer.isVisible()) {
        layer.render(this.canvas!);
      }
    });
  }

  invalidateRegion(x: number, y: number, width: number, height: number): void {
    this.layers.forEach(layer => {
      layer.invalidate(x, y, width, height);
    });
  }

  clear(): void {
    this.layers = [];
  }
}

export default RenderEngine;
