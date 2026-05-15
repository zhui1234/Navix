import { GridPos } from '../models/MapTypes'
import { AStarPathfinder } from './AStar'
import { GridMap, PathfindingOptions, PathfindingResult } from './PathfindingTypes'

export class DijkstraPathfinder {
  private impl: AStarPathfinder = new AStarPathfinder()

  findPath(map: GridMap, start: GridPos, end: GridPos, options: PathfindingOptions): PathfindingResult {
    const noHeuristic: PathfindingOptions = {
      allowDiagonal: options.allowDiagonal,
      heuristicType: 'manhattan',
      heuristicWeight: 0,
      onStep: options.onStep
    }
    return this.impl.findPath(map, start, end, noHeuristic)
  }
}
