import fs from'fs/promises'
import { getDiff } from '@/lib/diff'
export async function POST(req:Request){
 const {slug,original,edited,reviewer='anon'}=await req.json()
 const diff=getDiff(original,edited)
 await fs.mkdir('logs/review',{recursive:true})
 await fs.writeFile(`logs/review/${slug}.json`,JSON.stringify({slug,diff,reviewer,ts:Date.now()},null,2))
 return Response.json({ok:true})
}
