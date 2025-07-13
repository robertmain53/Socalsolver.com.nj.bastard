#!/bin/bash
set -euo pipefail

echo "🔁 Creating fallback homepage: /src/app/page.tsx"
mkdir -p src/app
cat > src/app/page.tsx <<'EOF'
export { default } from './[locale]/page'
EOF

echo "🔁 Creating localized homepage: /src/app/[locale]/page.tsx"
mkdir -p src/app/[locale]
cat > src/app/[locale]/page.tsx <<'EOF'
import { getDictionary } from '@/lib/i18n'
import { getLocale } from '@/lib/locale'
import Link from 'next/link'

export default async function Home() {
  const locale = getLocale()
  const t = await getDictionary(locale)

  return (
    <main className="p-8 max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-4">{t.home.title}</h1>
      <p className="text-lg mb-6">{t.home.description}</p>
      <ul className="grid gap-2">
        {['finance', 'health', 'math'].map(cat => (
          <li key={cat}>
            <Link href={`/${locale}/${cat}`} className="text-blue-600 underline">{t.categories[cat]?.title || cat}</Link>
          </li>
        ))}
      </ul>
    </main>
  )
}
EOF

echo "✅ Homepage fallback + localized route created"

echo "🔁 Patching search index builder"
cat > scripts/build-search-index.js <<'EOF'
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
EOF

echo "✅ Search index patched"

echo "🔁 Running sitemap and index..."
npm run generate-sitemap || echo "⚠️ Sitemap failed"
npm run build-search || echo "⚠️ Search index failed"

echo "✅ Done. Restart dev server with: npm run dev"
