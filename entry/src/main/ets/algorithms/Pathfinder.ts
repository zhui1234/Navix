import GridMap from '../data/GridMap';
import Cell from '../data/Cell';
import TimelineFrame from '../data/Timeline';

export interface PathResult {
  path: Cell[];
  found: boolean;
  metrics: AlgorithmMetrics;
}

export interface AlgorithmMetrics {
  nodesSearched: number;
  pathLength: number;
  executionTime: number;
  memoryUsage: number;
}

export enum HeuristicType {
  MANHATTAN = 'Manhattan',
  EUCLIDEAN = 'Euclidean',
  DIAGONAL = 'Diagonal'
}

export interface Pathfinder {
  name: string;
  id: string;
  description: string;

  findPath(
    start: Cell,
    end: Cell,
    map: GridMap,
    heuristic?: HeuristicType,
    onStep?: (frame: TimelineFrame) => void
  ): PathResult;
}

export abstract class BasePathfinder implements Pathfinder {
  abstract name: string;
  abstract id: string;
  abstract description: string;

  abstract findPath(
    start: Cell,
    end: Cell,
    map: GridMap,
    heuristic?: HeuristicType,
    onStep?: (frame: TimelineFrame) => void
  ): PathResult;

  protected createMetrics(): AlgorithmMetrics {
    return {
      nodesSearched: 0,
      pathLength: 0,
      executionTime: 0,
      memoryUsage: 0
    };
  }

  protected reconstructPath(cameFrom: Map<string, Cell>, current: Cell): Cell[] {
    const path: Cell[] = [current];
    let key = `${current.x},${current.y}`;

    while (cameFrom.has(key)) {
      const prev = cameFrom.get(key)!;
      path.unshift(prev);
      key = `${prev.x},${prev.y}`;
    }

    return path;
  }
}

export default BasePathfinder;
