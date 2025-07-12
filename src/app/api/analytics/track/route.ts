import fs from'fs/promises'
export async function POST(req:Request){
 const {slug}=await req.json()
 const f='data/analytics.json'
 let d:{}= {}
 try{d=JSON.parse(await fs.readFile(f,'utf8'))}catch{}
 d[slug]=(d[slug]||0)+1
 await fs.mkdir('data',{recursive:true});await fs.writeFile(f,JSON.stringify(d,null,2))
 return Response.json({ok:true})
}
