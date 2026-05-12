import Cell from '../../data/Cell';

const SQRT2 = Math.sqrt(2);

export function Diagonal(a: Cell, b: Cell): number {
  const dx = Math.abs(a.x - b.x);
  const dy = Math.abs(a.y - b.y);
  return dx + dy + (SQRT2 - 2) * Math.min(dx, dy);
}

export default Diagonal;
