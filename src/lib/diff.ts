import { diffLines } from 'diff'
export function getDiff(before: string, after: string): string {
  return diffLines(before, after)
    .map(p => (p.added ? '[+]' : p.removed ? '[-]' : '[ ]') + p.value)
    .join('')
}
