// scripts/generate-sitemap.ts
/**
 * Generate multilingual sitemap.xml from category JSON tree
 * --------------------------------------------------------
 * Run with:  npx ts-node scripts/generate-sitemap.ts
 * Output:    public/sitemap.xml
 */
import fs from 'fs/promises'
import path from 'path'

const BASE_URL = 'https://socalsolver.com'
const CATS_DIR = path.join(process.cwd(), 'content/categories')
const DIST_FILE = path.join(process.cwd(), 'public/sitemap.xml')

/* -------- helpers -------- */
const loadJSON = async (file: string): Promise<any> =>
  JSON.parse(await fs.readFile(file, 'utf8'))

function flatten(tree: any, prefix = ''): string[] {
  const routes: string[] = []
  for (const [slug, node] of Object.entries(tree)) {
    const level1 = `${prefix}/${slug}`
    routes.push(level1)
    if (node && typeof node === 'object' && node.children) {
      for (const [sub, subNode] of Object.entries(node.children)) {
        const level2 = `${level1}/${sub}`
        routes.push(level2)
        if (subNode && typeof subNode === 'object' && subNode.children) {
          for (const subsub of Object.keys(subNode.children))
            routes.push(`${level2}/${subsub}`)
        }
      }
    }
  }
  return routes
}

/* -------- main -------- */
async function main() {
  // detect all locale JSON files in /content/categories
  const localeFiles = (await fs.readdir(CATS_DIR)).filter(f => f.endsWith('.json'))
  const locales = localeFiles.map(f => f.replace(/\\.json$/, ''))

  // use English file for structure
  const enTree = await loadJSON(path.join(CATS_DIR, 'en.json'))
  const paths = flatten(enTree)

  let xml = '<?xml version="1.0" encoding="UTF-8"?>\\n'
  xml += '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\\n'

  for (const locale of locales) {
    for (const p of paths) {
      xml += `  <url><loc>${BASE_URL}/${locale}${p}</loc></url>\\n`
    }
  }

  xml += '</urlset>\\n'
  await fs.mkdir(path.dirname(DIST_FILE), { recursive: true })
  await fs.writeFile(DIST_FILE, xml)
  console.log('✅ sitemap.xml generated:', DIST_FILE)
}

main().catch(err => {
  console.error('❌ Sitemap generation failed:', err)
  process.exit(1)
})
