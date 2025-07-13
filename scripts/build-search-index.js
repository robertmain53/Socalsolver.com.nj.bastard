import fs from 'fs'
import path from 'path'

const genDir = path.join(process.cwd(), 'generated', 'calculators')
const outFile = path.join(process.cwd(), 'public', 'search-index.json')

let index = []

if (fs.existsSync(genDir)) {
  const files = fs.readdirSync(genDir)
  for (const file of files) {
    const slug = file.replace('.js', '')
    index.push({ slug, title: slug.replace(/-/g, ' ') })
  }
}

fs.writeFileSync(outFile, JSON.stringify(index, null, 2))
console.log(`🔍 Indexed ${index.length} calculators`)
