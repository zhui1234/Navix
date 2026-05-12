import { BasePathfinder, PathResult, AlgorithmMetrics } from './Pathfinder';
import GridMap from '../data/GridMap';
import Cell from '../data/Cell';
import PriorityQueue from '../utils/PriorityQueue';

export class Dijkstra extends BasePathfinder {
  name = 'Dijkstra';
  id = 'dijkstra';
  description = 'Dijkstra算法 - 基于边权重的最短路径算法';

  findPath(
    start: Cell,
    end: Cell,
    map: GridMap,
    onStep?: (frame: TimelineFrame) => void
  ): PathResult {
    const startTime = performance.now();
    const metrics: AlgorithmMetrics = this.createMetrics();

    const openSet = new PriorityQueue<Cell>();
    const cameFrom = new Map<string, Cell>();
    const dist = new Map<string, number>();

    const startKey = `${start.x},${start.y}`;
    const endKey = `${end.x},${end.y}`;

    dist.set(startKey, 0);
    openSet.enqueue(start, 0);

    const openSetCells = new Set<string>();
    const closedSetCells = new Set<string>();
    openSetCells.add(startKey);

    while (!openSet.isEmpty()) {
      const current = openSet.dequeue()!;
      const currentKey = `${current.x},${current.y}`;

      openSetCells.delete(currentKey);
      closedSetCells.add(currentKey);
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

        if (closedSetCells.has(neighborKey) || neighbor.isObstacle) {
          continue;
        }

        const tentativeDist = (dist.get(currentKey) ?? Infinity) + neighbor.terrainCost;
        metrics.memoryUsage++;

        if (!dist.has(neighborKey) || tentativeDist < dist.get(neighborKey)!) {
          cameFrom.set(neighborKey, current);
          dist.set(neighborKey, tentativeDist);

          if (!openSetCells.has(neighborKey)) {
            openSet.enqueue(neighbor, tentativeDist);
            openSetCells.add(neighborKey);
          }
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

export default Dijkstra;
