import fs from'fs/promises'
export async function POST(req:Request){
 const b=await req.json();await fs.writeFile(`drafts/${b.slug}.json`,JSON.stringify(b,null,2))
 return Response.json({ok:true})
}
