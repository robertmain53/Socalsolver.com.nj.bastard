import fs from 'fs/promises'
import path from 'path'
const SRC = 'content/calculators'
const DEST = 'public/search-index.json'
const list = await fs.readdir(SRC)
const out = []
for (const file of list.filter(f=>f.endsWith('.json'))) {
  const data = JSON.parse(await fs.readFile(path.join(SRC,file),'utf8'))
  out.push({ slug: data.slug, title: data.title?.en || data.slug })
}
await fs.mkdir('public',{recursive:true})
await fs.writeFile(DEST, JSON.stringify(out))
console.log('✅ search-index.json written')
