import Cell from '../../data/Cell';

export function getHeuristic(heuristicType: string): (a: Cell, b: Cell) => number {
  switch (heuristicType) {
    case 'Manhattan':
      return Manhattan;
    case 'Euclidean':
      return Euclidean;
    case 'Diagonal':
      return Diagonal;
    default:
      return Manhattan;
  }
}

export function Manhattan(a: Cell, b: Cell): number {
  return Math.abs(a.x - b.x) + Math.abs(a.y - b.y);
}

export function Euclidean(a: Cell, b: Cell): number {
  return Math.sqrt(Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2));
}

export function Diagonal(a: Cell, b: Cell): number {
  const dx = Math.abs(a.x - b.x);
  const dy = Math.abs(a.y - b.y);
  return dx + dy + (Math.SQRT2 - 2) * Math.min(dx, dy);
}

export default Manhattan;
