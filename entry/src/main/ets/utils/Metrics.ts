import { AlgorithmMetrics } from '../algorithms/Pathfinder';

export class Metrics {
  private startTime: number = 0;
  private endTime: number = 0;
  private nodesSearched: number = 0;
  private memorySnapshots: number[] = [];

  start(): void {
    this.startTime = performance.now();
    this.nodesSearched = 0;
    this.memorySnapshots = [];
  }

  end(): void {
    this.endTime = performance.now();
    this.recordMemory();
  }

  incrementNodes(): void {
    this.nodesSearched++;
  }

  recordMemory(): void {
    if (typeof process !== 'undefined' && process.memoryUsage) {
      const mem = process.memoryUsage();
      this.memorySnapshots.push(mem.heapUsed);
    }
  }

  getCurrentMemory(): number {
    if (typeof process !== 'undefined' && process.memoryUsage) {
      return process.memoryUsage().heapUsed;
    }
    return 0;
  }

  getMetrics(): AlgorithmMetrics {
    return {
      nodesSearched: this.nodesSearched,
      pathLength: 0,
      executionTime: this.endTime - this.startTime,
      memoryUsage: this.getCurrentMemory()
    };
  }

  reset(): void {
    this.startTime = 0;
    this.endTime = 0;
    this.nodesSearched = 0;
    this.memorySnapshots = [];
  }
}

export default Metrics;
