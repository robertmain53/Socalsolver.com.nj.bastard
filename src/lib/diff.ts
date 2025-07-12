import { diffLines } from 'diff'
export function getDiff(a:string,b:string){
 return diffLines(a,b).map(p=>(p.added?'[+]':p.removed?'[-]':'[ ]')+p.value).join('')
}
