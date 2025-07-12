import fs from'fs/promises'
export const runtime='edge'
export async function GET(){
 const files = await fs.readdir('logs/review').catch(()=>[])
 const logs = await Promise.all(files.map(f=>fs.readFile(`logs/review/${f}`,'utf8').then(JSON.parse)))
 return Response.json({logs})
}
