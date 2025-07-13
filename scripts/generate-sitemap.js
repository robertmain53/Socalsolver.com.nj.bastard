/**
 * Generate multilingual sitemap.xml from category JSON
 * ---------------------------------------------------
 * Usage:  node scripts/generate-sitemap.js
 */
import fs from 'fs/promises';
import path from 'path';

const BASE_URL = 'https://socalsolver.com';
const CAT_DIR  = 'content/categories';
const OUT_FILE = 'public/sitemap.xml';

/* helper: flatten tree to routes */
function flatten(tree, prefix = '') {
  const routes = [];
  for (const [slug, node] of Object.entries(tree)) {
    const lvl1 = `${prefix}/${slug}`;
    routes.push(lvl1);

    if (node?.children) {
      for (const [sub, subNode] of Object.entries(node.children)) {
        const lvl2 = `${lvl1}/${sub}`;
        routes.push(lvl2);

        if (subNode?.children) {
          for (const subsub of Object.keys(subNode.children)) {
            routes.push(`${lvl2}/${subsub}`);
          }
        }
      }
    }
  }
  return routes;
}

async function main() {
  // detect locales by JSON files
  const localeFiles = (await fs.readdir(CAT_DIR)).filter(f => f.endsWith('.json'));
  const locales = localeFiles.map(f => f.replace('.json', ''));

  const enTree = JSON.parse(await fs.readFile(path.join(CAT_DIR, 'en.json'), 'utf8'));
  const routes = flatten(enTree);

let xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
`;

for (const locale of locales) {
  for (const r of routes) {
    xml += `  <url><loc>${BASE_URL}/${locale}${r}</loc></url>\n`;
  }
}

xml += '</urlset>\n';


  await fs.mkdir(path.dirname(OUT_FILE), { recursive: true });
  await fs.writeFile(OUT_FILE, xml);
  console.log('✅  Sitemap generated ->', OUT_FILE);
}

main().catch(e => {
  console.error('❌  sitemap generation failed', e);
  process.exit(1);
});
