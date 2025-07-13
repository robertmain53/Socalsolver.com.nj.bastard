#!/usr/bin/env bash
# Run: bash fix-i18n-and-refactor.sh
set -euo pipefail
IFS=$'\n\t'

# 0. Remove hard-coded locale folders if present
for L in en fr es it; do
  [ -d "src/app/$L" ] && rm -rf "src/app/$L"
done

# 1. Ensure dynamic locale folder exists
mkdir -p src/app/[locale]
touch src/app/[locale]/page.tsx

# 2. Add middleware for / → /en redirect
cat > middleware.ts <<'TS'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(req: NextRequest) {
  if (req.nextUrl.pathname === '/') {
    return NextResponse.redirect(new URL('/en', req.url))
  }
  return NextResponse.next()
}
TS

# 3. Header component
mkdir -p src/components/layout
cat > src/components/layout/Header.tsx <<'TSX'
'use client'
import Link from 'next/link'
import { usePathname } from 'next/navigation'

const labels = { en: 'Home', fr: 'Accueil', es: 'Inicio', it: 'Home' }

export default function Header() {
  const path = usePathname()
  const locale = path.split('/')[1] || 'en'
  return (
    <header className="py-4 border-b flex gap-6 px-4">
      <Link href={`/${locale}`} className="font-bold text-lg">SoCalSolver</Link>
      <Link href={`/${locale}`}>{labels[locale] || 'Home'}</Link>
    </header>
  )
}
TSX

# 4. Footer component
cat > src/components/layout/Footer.tsx <<'TSX'
'use client'
import { usePathname } from 'next/navigation'
export default function Footer() {
  const locale = usePathname().split('/')[1] || 'en'
  const year = new Date().getFullYear()
  return (
    <footer className="py-6 text-center text-sm text-gray-500 border-t mt-16">
      © {year} SoCalSolver – {locale.toUpperCase()}
    </footer>
  )
}
TSX

# 5. Breadcrumbs component
cat > src/components/Breadcrumbs.tsx <<'TSX'
import Link from 'next/link'

export default function Breadcrumbs({ segments }: { segments: string[] }) {
  const locale = segments[0]
  const trail = segments.slice(1)
  let path = `/${locale}`
  return (
    <nav className="text-sm mb-4">
      <ol className="flex gap-1 text-blue-700 flex-wrap">
        <li><Link href={path}>Home</Link></li>
        {trail.map((seg, i) => {
          path += `/${seg}`
          return (
            <li key={i} className="flex gap-1">
              <span>/</span>
              <Link href={path}>{seg.replace(/-/g,' ')}</Link>
            </li>
          )
        })}
      </ol>
    </nav>
  )
}
TSX

# 6. Author components
mkdir -p src/components/author
cat > src/components/author/AuthorCard.tsx <<'TSX'
import AuthorSchema from './AuthorSchema'
export default function AuthorCard({ author }) {
  return (
    <aside className="p-4 border rounded bg-gray-50 mt-8">
      <AuthorSchema {...author} />
      <h3 className="font-semibold">{author.name}</h3>
      <p className="text-sm">{author.bio}</p>
    </aside>
  )
}
TSX
cat > src/components/author/AuthorSchema.tsx <<'TSX'
'use client'
import Script from 'next/script'
export default function AuthorSchema({ name, url, bio }) {
  const data = { '@context':'https://schema.org','@type':'Person',name,url,description:bio}
  return <Script id="author-json" type="application/ld+json" dangerouslySetInnerHTML={{__html:JSON.stringify(data)}} />
}
TSX

# 7. Search-index builder
mkdir -p scripts
cat > scripts/build-search-index.js <<'JS'
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
JS

# 8. Package.json scripts
npx json -I -f package.json -e 'this.scripts["build-search"]="node scripts/build-search-index.js"'

echo "🌍  Refactor complete. Run npm run dev and visit http://localhost:3000/en"
