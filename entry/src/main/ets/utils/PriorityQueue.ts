export interface QueueItem<T> {
  item: T;
  priority: number;
}

export class PriorityQueue<T> {
  private heap: QueueItem<T>[] = [];

  enqueue(item: T, priority: number): void {
    this.heap.push({ item, priority });
    this.bubbleUp(this.heap.length - 1);
  }

  dequeue(): T | undefined {
    if (this.isEmpty()) {
      return undefined;
    }

    const min = this.heap[0].item;
    const last = this.heap.pop()!;

    if (this.heap.length > 0) {
      this.heap[0] = last;
      this.bubbleDown(0);
    }

    return min;
  }

  peek(): T | undefined {
    return this.heap[0]?.item;
  }

  isEmpty(): boolean {
    return this.heap.length === 0;
  }

  size(): number {
    return this.heap.length;
  }

  clear(): void {
    this.heap = [];
  }

  private bubbleUp(index: number): void {
    while (index > 0) {
      const parentIndex = Math.floor((index - 1) / 2);
      if (this.heap[parentIndex].priority <= this.heap[index].priority) {
        break;
      }
      this.swap(parentIndex, index);
      index = parentIndex;
    }
  }

  private bubbleDown(index: number): void {
    while (true) {
      const leftChild = 2 * index + 1;
      const rightChild = 2 * index + 2;
      let smallest = index;

      if (
        leftChild < this.heap.length &&
        this.heap[leftChild].priority < this.heap[smallest].priority
      ) {
        smallest = leftChild;
      }

      if (
        rightChild < this.heap.length &&
        this.heap[rightChild].priority < this.heap[smallest].priority
      ) {
        smallest = rightChild;
      }

      if (smallest === index) {
        break;
      }

      this.swap(smallest, index);
      index = smallest;
    }
  }

  private swap(i: number, j: number): void {
    const temp = this.heap[i];
    this.heap[i] = this.heap[j];
    this.heap[j] = temp;
  }
}

export default PriorityQueue;
