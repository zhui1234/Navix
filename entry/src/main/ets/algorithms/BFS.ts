import { BasePathfinder, PathResult, AlgorithmMetrics } from './Pathfinder';
import GridMap from '../data/GridMap';
import Cell from '../data/Cell';

export class BFS extends BasePathfinder {
  name = 'BFS';
  id = 'bfs';
  description = '广度优先搜索 - 盲目搜索算法，保证找到最短路径';

  findPath(
    start: Cell,
    end: Cell,
    map: GridMap,
    onStep?: (frame: TimelineFrame) => void
  ): PathResult {
    const startTime = performance.now();
    const metrics: AlgorithmMetrics = this.createMetrics();

    const queue: Cell[] = [start];
    const visited = new Set<string>();
    const cameFrom = new Map<string, Cell>();

    const startKey = `${start.x},${start.y}`;
    const endKey = `${end.x},${end.y}`;

    visited.add(startKey);

    while (queue.length > 0) {
      const current = queue.shift()!;
      const currentKey = `${current.x},${current.y}`;

      metrics.nodesSearched++;

      if (currentKey === endKey) {
        const path = this.reconstructPath(cameFrom, current);
        metrics.pathLength = path.length;
        metrics.executionTime = performance.now() - startTime;

        return {
          path,
          found: true,
          metrics
        };
      }

      const neighbors = map.getNeighbors(current);

      for (const neighbor of neighbors) {
        const neighborKey = `${neighbor.x},${neighbor.y}`;

        if (!visited.has(neighborKey) && !neighbor.isObstacle) {
          visited.add(neighborKey);
          cameFrom.set(neighborKey, current);
          queue.push(neighbor);
          metrics.memoryUsage++;
        }
      }
    }

    metrics.executionTime = performance.now() - startTime;

    return {
      path: [],
      found: false,
      metrics
    };
  }
}

import TimelineFrame from '../data/Timeline';

export default BFS;
