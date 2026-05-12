import Cell from '../../data/Cell';

export function Euclidean(a: Cell, b: Cell): number {
  return Math.sqrt(Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2));
}

export default Euclidean;
