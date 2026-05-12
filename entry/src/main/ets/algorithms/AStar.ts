import { BasePathfinder, PathResult, HeuristicType, AlgorithmMetrics } from './Pathfinder';
import GridMap from '../data/GridMap';
import Cell from '../data/Cell';
import TimelineFrame from '../data/Timeline';
import PriorityQueue from '../utils/PriorityQueue';
import { getHeuristic } from './heuristics/Manhattan';

export class AStar extends BasePathfinder {
  name = 'A*';
  id = 'astar';
  description = 'A*寻路算法 - 结合启发式搜索的最优路径算法';

  findPath(
    start: Cell,
    end: Cell,
    map: GridMap,
    heuristic: HeuristicType = HeuristicType.MANHATTAN,
    onStep?: (frame: TimelineFrame) => void
  ): PathResult {
    const startTime = performance.now();
    const metrics: AlgorithmMetrics = this.createMetrics();

    const openSet = new PriorityQueue<Cell>();
    const cameFrom = new Map<string, Cell>();
    const gScore = new Map<string, number>();
    const fScore = new Map<string, number>();

    const startKey = `${start.x},${start.y}`;
    const endKey = `${end.x},${end.y}`;

    gScore.set(startKey, 0);
    fScore.set(startKey, this.calculateHeuristic(start, end, heuristic));
    openSet.enqueue(start, fScore.get(startKey)!);

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

      if (onStep) {
        const frame = new TimelineFrame(
          metrics.nodesSearched,
          performance.now() - startTime,
          Array.from(openSetCells).map(k => this.parseKey(k)),
          Array.from(closedSetCells).map(k => this.parseKey(k)),
          current,
          undefined,
          new Map(gScore),
          new Map(fScore),
          metrics
        );
        onStep(frame);
      }

      const neighbors = map.getNeighbors(current);

      for (const neighbor of neighbors) {
        const neighborKey = `${neighbor.x},${neighbor.y}`;

        if (closedSetCells.has(neighborKey) || neighbor.isObstacle) {
          continue;
        }

        const tentativeG = (gScore.get(currentKey) ?? Infinity) + neighbor.terrainCost;
        metrics.memoryUsage++;

        if (!gScore.has(neighborKey) || tentativeG < gScore.get(neighborKey)!) {
          cameFrom.set(neighborKey, current);
          gScore.set(neighborKey, tentativeG);
          fScore.set(neighborKey, tentativeG + this.calculateHeuristic(neighbor, end, heuristic));

          if (!openSetCells.has(neighborKey)) {
            openSet.enqueue(neighbor, fScore.get(neighborKey)!);
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

  private calculateHeuristic(cell: Cell, goal: Cell, type: HeuristicType): number {
    switch (type) {
      case HeuristicType.MANHATTAN:
        return Math.abs(cell.x - goal.x) + Math.abs(cell.y - goal.y);
      case HeuristicType.EUCLIDEAN:
        return Math.sqrt(Math.pow(cell.x - goal.x, 2) + Math.pow(cell.y - goal.y, 2));
      case HeuristicType.DIAGONAL:
        const dx = Math.abs(cell.x - goal.x);
        const dy = Math.abs(cell.y - goal.y);
        return dx + dy + (Math.SQRT2 - 2) * Math.min(dx, dy);
      default:
        return Math.abs(cell.x - goal.x) + Math.abs(cell.y - goal.y);
    }
  }

  private parseKey(key: string): Cell {
    const [x, y] = key.split(',').map(Number);
    return new Cell(x, y);
  }
}

export default AStar;
