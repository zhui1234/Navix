export class HeapNode {
  id: number
  priority: number

  constructor(id: number, priority: number) {
    this.id = id
    this.priority = priority
  }
}

export class MinHeap {
  private data: HeapNode[] = []

  size(): number {
    return this.data.length
  }

  ids(): number[] {
    const res: number[] = []
    for (let i = 0; i < this.data.length; i++) {
      res.push(this.data[i].id)
    }
    return res
  }

  push(node: HeapNode): void {
    this.data.push(node)
    this.bubbleUp(this.data.length - 1)
  }

  pop(): HeapNode | null {
    if (this.data.length === 0) {
      return null
    }
    const top = this.data[0]
    const last = this.data.pop()!
    if (this.data.length > 0) {
      this.data[0] = last
      this.bubbleDown(0)
    }
    return top
  }

  private bubbleUp(index: number): void {
    let i = index
    while (i > 0) {
      const p = (i - 1) >> 1
      if (this.data[p].priority <= this.data[i].priority) {
        break
      }
      const tmp = this.data[p]
      this.data[p] = this.data[i]
      this.data[i] = tmp
      i = p
    }
  }

  private bubbleDown(index: number): void {
    let i = index
    const n = this.data.length
    while (true) {
      const l = i * 2 + 1
      const r = l + 1
      if (l >= n) {
        break
      }
      let m = l
      if (r < n && this.data[r].priority < this.data[l].priority) {
        m = r
      }
      if (this.data[i].priority <= this.data[m].priority) {
        break
      }
      const tmp = this.data[i]
      this.data[i] = this.data[m]
      this.data[m] = tmp
      i = m
    }
  }
}
