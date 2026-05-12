import GridMap from '../data/GridMap';

export interface SerializedMap {
  rows: number;
  cols: number;
  cells: SerializedCell[];
}

export interface SerializedCell {
  x: number;
  y: number;
  isObstacle: boolean;
  terrainCost: number;
}

export class Serializer {
  static serializeMap(map: GridMap): string {
    const data: SerializedMap = {
      rows: map.getRows(),
      cols: map.getCols(),
      cells: []
    };

    for (let i = 0; i < map.getRows(); i++) {
      for (let j = 0; j < map.getCols(); j++) {
        const cell = map.getCell(i, j);
        if (cell) {
          data.cells.push({
            x: cell.x,
            y: cell.y,
            isObstacle: cell.isObstacle,
            terrainCost: cell.terrainCost
          });
        }
      }
    }

    return JSON.stringify(data);
  }

  static deserializeMap(json: string): GridMap | null {
    try {
      const data: SerializedMap = JSON.parse(json);
      const map = new GridMap(data.rows, data.cols);

      for (const cellData of data.cells) {
        const cell = map.getCell(cellData.x, cellData.y);
        if (cell) {
          cell.setObstacle(cellData.isObstacle);
          cell.setTerrainCost(cellData.terrainCost);
        }
      }

      return map;
    } catch (e) {
      console.error('Failed to deserialize map:', e);
      return null;
    }
  }

  static exportMap(map: GridMap, filename: string): void {
    const json = this.serializeMap(map);
    console.log(`Map exported to ${filename}:`, json);
  }

  static importMap(json: string): GridMap | null {
    return this.deserializeMap(json);
  }
}

export default Serializer;
