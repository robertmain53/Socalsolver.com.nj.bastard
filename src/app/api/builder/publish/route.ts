import fs from'fs/promises'
import { exec } from'child_process'
import { promisify } from'node:util'
const sh=promisify(exec)
export async function POST(req:Request){
 const {slug,lang='en',bundle,reviewer='sys'}=await req.json()
 const dest=`content/calculators/${slug}.${lang}.json`
 await fs.mkdir('content/calculators',{recursive:true})
 await fs.writeFile(dest,JSON.stringify(bundle,null,2))
 try{await sh(`git add ${dest} && git commit -m "✅ Publish ${slug}.${lang}" && git push`)}catch{}
 await fs.appendFile('CHANGELOG.md',`\n- ${new Date().toISOString()} ${slug}.${lang} (${reviewer})`)
 return Response.json({ok:true})
}
