#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

### 0 — Prerequisites ---------------------------------------------------------
for c in git npm npx; do command -v $c >/dev/null || { echo "❌ $c not found"; exit 1; }; done

### 1 — Remove legacy /pages & hard-coded locale dirs -------------------------
echo "🧹 Cleaning legacy folders…"
rm -rf src/pages               # remove old Pages router
for L in en es fr it; do
  rm -rf "src/app/$L" || true  # remove hard-coded locales
done

### 2 — Ensure dynamic locale structure --------------------------------------
echo "🗂️  Creating dynamic [locale] routes…"
mkdir -p src/app/[locale]
cat > src/app/[locale]/layout.tsx <<'TSX'
import Header from '@/components/layout/Header'
import Footer from '@/components/layout/Footer'

export default function LocaleLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen flex flex-col">
        <Header />
        <div className="flex-grow">{children}</div>
        <Footer />
      </body>
    </html>
  )
}
TSX

cat > src/app/[locale]/page.tsx <<'TSX'
import { notFound } from 'next/navigation'

const msg = {
  en: { hero: 'Smart calculators for every need.' },
  es: { hero: 'Calculadoras inteligentes para cada necesidad.' },
  fr: { hero: 'Des calculatrices intelligentes pour chaque besoin.' },
  it: { hero: 'Calcolatrici intelligenti per ogni esigenza.' },
}

export default function Home({ params }: { params: { locale: string } }) {
  const t = msg[params.locale as keyof typeof msg]
  if (!t) return notFound()

  return (
    <main className="py-20 text-center">
      <h1 className="text-4xl font-bold mb-4">SoCalSolver</h1>
      <p className="text-xl text-gray-600">{t.hero}</p>
    </main>
  )
}
TSX

### 3 — Header & Footer components -------------------------------------------
mkdir -p src/components/layout
cat > src/components/layout/Header.tsx <<'TSX'
'use client'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
export default function Header() {
  const locale = (usePathname().split('/')[1] || 'en') as string
  return (
    <header className="px-6 py-4 border-b flex gap-6">
      <Link href={`/${locale}`} className="font-bold">SoCalSolver</Link>
    </header>
  )
}
TSX
cat > src/components/layout/Footer.tsx <<'TSX'
export default function Footer() {
  return (
    <footer className="py-6 text-center text-sm text-gray-500 border-t">
      © {new Date().getFullYear()} SoCalSolver
    </footer>
  )
}
TSX

### 4 — Middleware redirect ---------------------------------------------------
cat > middleware.ts <<'TS'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
export function middleware(req: NextRequest) {
  if (req.nextUrl.pathname === '/') return NextResponse.redirect(new URL('/en', req.url))
  return NextResponse.next()
}
TS

### 5 — Patch next.config.js --------------------------------------------------
echo "⚙️  Patching next.config.js…"
npx replace-in-file \
  "module.exports = {" \
  "module.exports = {\n  i18n: { locales: ['en','es','fr','it'], defaultLocale: 'en', localeDetection: false }," \
  next.config.js

### 6 — Safe calculator registry fallback ------------------------------------
mkdir -p src/lib
cat > src/lib/calculator-registry.ts <<'TS'
export async function loadCalculator(slug: string) {
  try {
    return (await import(`../../generated/calculators/${slug}.js`)).default
  } catch {
    console.warn('⚠️ missing calculator:', slug)
    return null
  }
}
TS

### 7 — Fix sitemap & search-index scripts ------------------------------------
mkdir -p scripts public content/calculators
cat > scripts/generate-sitemap.js <<'JS'
import fs from 'fs/promises'; import path from 'path'
const base = 'https://socalsolver.com'
const tree = JSON.parse(await fs.readFile('content/categories/en.json','utf8'))
const locales = ['en','es','fr','it']
const out = []
;(() => { const walk=(o,p='')=>{for(const [k,v] of Object.entries(o)){const n=`${p}/${k}`;out.push(n);v.children&&walk(v.children,n)}};walk(tree) })()
let xml=`<?xml version="1.0" encoding="UTF-8"?>\\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\\n`
for(const l of locales) for(const p of out) xml+=`  <url><loc>${base}/${l}${p}</loc></url>\\n`
xml+='</urlset>\\n'
await fs.writeFile('public/sitemap.xml',xml); console.log('✅ sitemap.xml')
JS

cat > scripts/build-search-index.js <<'JS'
import fs from 'fs/promises'; import path from 'path'
const files = (await fs.readdir('content/calculators')).filter(f=>f.endsWith('.json'))
const idx=[]
for(const f of files){const d=JSON.parse(await fs.readFile(path.join('content/calculators',f),'utf8'));idx.push({slug:d.slug,title:d.title?.en||d.slug})}
await fs.writeFile('public/search-index.json',JSON.stringify(idx))
console.log('✅ search-index.json')
JS

### 8 — Add npm scripts & dev-deps -------------------------------------------
npx json -I -f package.json -e 'this.scripts["generate-sitemap"]="node scripts/generate-sitemap.js"; this.scripts["build-search"]="node scripts/build-search-index.js"'

npm install -D json replace-in-file

### 9 — Reset Next.js cache & start dev --------------------------------------
rm -rf .next
echo "🚀  Starting dev server on :3000 …"
npm run dev
