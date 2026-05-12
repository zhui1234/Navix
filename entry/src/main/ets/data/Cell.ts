export class Cell {
  x: number;
  y: number;
  isObstacle: boolean = false;
  terrainCost: number = 1;
  parent: Cell | null = null;

  gScore: number = Infinity;
  fScore: number = Infinity;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }

  setObstacle(isObstacle: boolean): void {
    this.isObstacle = isObstacle;
    if (isObstacle) {
      this.terrainCost = Infinity;
    }
  }

  setTerrainCost(cost: number): void {
    this.terrainCost = cost;
  }

  reset(): void {
    this.gScore = Infinity;
    this.fScore = Infinity;
    this.parent = null;
  }

  equals(other: Cell): boolean {
    return this.x === other.x && this.y === other.y;
  }

  toKey(): string {
    return `${this.x},${this.y}`;
  }

  static fromKey(key: string): Cell {
    const [x, y] = key.split(',').map(Number);
    return new Cell(x, y);
  }
}

export default Cell;
