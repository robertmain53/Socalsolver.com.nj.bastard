import { OpenAI } from 'openai'
import { getDiff } from '@/lib/diff'
export const runtime='edge'
export async function POST(req:Request){
 const {original='',edited=''} = await req.json()
 const diff = getDiff(original,edited)
 const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY })
 const r = await openai.chat.completions.create({
   model:'gpt-4o-mini',
   messages:[{role:'system',content:'Improve:'},{role:'user',content:diff}]
 })
 return Response.json({ improved:r.choices[0].message.content,diff })
}
