import Cell from './Cell';

export class GridMap {
  private grid: Cell[][] = [];
  private rows: number = 0;
  private cols: number = 0;

  constructor(rows: number = 20, cols: number = 20) {
    this.initialize(rows, cols);
  }

  private initialize(rows: number, cols: number): void {
    this.rows = rows;
    this.cols = cols;
    this.grid = [];

    for (let i = 0; i < rows; i++) {
      let row: Cell[] = [];
      for (let j = 0; j < cols; j++) {
        row.push(new Cell(i, j));
      }
      this.grid.push(row);
    }
  }

  getCell(x: number, y: number): Cell | null {
    if (x >= 0 && x < this.rows && y >= 0 && y < this.cols) {
      return this.grid[x][y];
    }
    return null;
  }

  setCell(x: number, y: number, cell: Cell): void {
    if (x >= 0 && x < this.rows && y >= 0 && y < this.cols) {
      this.grid[x][y] = cell;
    }
  }

  getNeighbors(cell: Cell): Cell[] {
    const neighbors: Cell[] = [];
    const directions = [
      [-1, 0], [1, 0], [0, -1], [0, 1],
      [-1, -1], [-1, 1], [1, -1], [1, 1]
    ];

    for (const [dx, dy] of directions) {
      const nx = cell.x + dx;
      const ny = cell.y + dy;
      const neighbor = this.getCell(nx, ny);

      if (neighbor && !neighbor.isObstacle) {
        if (Math.abs(dx) + Math.abs(dy) === 2) {
          const diag1 = this.getCell(cell.x + dx, cell.y);
          const diag2 = this.getCell(cell.x, cell.y + dy);
          if (diag1?.isObstacle || diag2?.isObstacle) {
            continue;
          }
          neighbor.terrainCost = Math.SQRT2;
        }
        neighbors.push(neighbor);
      }
    }

    return neighbors;
  }

  getRows(): number {
    return this.rows;
  }

  getCols(): number {
    return this.cols;
  }

  reset(): void {
    for (let i = 0; i < this.rows; i++) {
      for (let j = 0; j < this.cols; j++) {
        this.grid[i][j].reset();
      }
    }
  }

  clear(): void {
    for (let i = 0; i < this.rows; i++) {
      for (let j = 0; j < this.cols; j++) {
        this.grid[i][j].setObstacle(false);
        this.grid[i][j].terrainCost = 1;
        this.grid[i][j].reset();
      }
    }
  }

  resize(rows: number, cols: number): void {
    this.initialize(rows, cols);
  }
}

export default GridMap;
