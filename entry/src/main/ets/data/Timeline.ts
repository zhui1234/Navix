import Cell from './Cell';
import { AlgorithmMetrics } from '../algorithms/Pathfinder';

export class TimelineFrame {
  step: number;
  timestamp: number;
  openSet: Cell[];
  closedSet: Cell[];
  current?: Cell;
  path?: Cell[];
  gScore: Map<string, number>;
  fScore: Map<string, number>;
  metrics: AlgorithmMetrics;

  constructor(
    step: number,
    timestamp: number,
    openSet: Cell[],
    closedSet: Cell[],
    current?: Cell,
    path?: Cell[],
    gScore?: Map<string, number>,
    fScore?: Map<string, number>,
    metrics?: AlgorithmMetrics
  ) {
    this.step = step;
    this.timestamp = timestamp;
    this.openSet = openSet;
    this.closedSet = closedSet;
    this.current = current;
    this.path = path;
    this.gScore = gScore ?? new Map();
    this.fScore = fScore ?? new Map();
    this.metrics = metrics ?? {
      nodesSearched: 0,
      pathLength: 0,
      executionTime: 0,
      memoryUsage: 0
    };
  }
}

export class Timeline {
  private frames: TimelineFrame[] = [];
  private currentIndex: number = 0;
  private maxFrames: number = 10000;

  addFrame(frame: TimelineFrame): void {
    if (this.frames.length < this.maxFrames) {
      this.frames.push(frame);
    }
  }

  getFrame(index: number): TimelineFrame | null {
    if (index >= 0 && index < this.frames.length) {
      return this.frames[index];
    }
    return null;
  }

  getCurrentFrame(): TimelineFrame | null {
    return this.getFrame(this.currentIndex);
  }

  next(): TimelineFrame | null {
    if (this.currentIndex < this.frames.length - 1) {
      this.currentIndex++;
      return this.frames[this.currentIndex];
    }
    return null;
  }

  previous(): TimelineFrame | null {
    if (this.currentIndex > 0) {
      this.currentIndex--;
      return this.frames[this.currentIndex];
    }
    return null;
  }

  goTo(index: number): TimelineFrame | null {
    if (index >= 0 && index < this.frames.length) {
      this.currentIndex = index;
      return this.frames[this.currentIndex];
    }
    return null;
  }

  getTotalFrames(): number {
    return this.frames.length;
  }

  getCurrentIndex(): number {
    return this.currentIndex;
  }

  clear(): void {
    this.frames = [];
    this.currentIndex = 0;
  }

  getFrames(): TimelineFrame[] {
    return this.frames;
  }

  setPlaybackSpeed(speed: number): void {
  }
}

export default Timeline;
