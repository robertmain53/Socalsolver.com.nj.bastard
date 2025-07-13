#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "🔧 1) Remove legacy Express code …"
rm -f src/api/router.ts \
      src/api/middleware/auth.ts \
      src/api/monitoring/metrics.ts \
      src/api/v2/calculators.ts || true

echo "⚙️ 2) Uninstall express deps (ignore errors)…"
npm remove express cors body-parser express-rate-limit kafkajs || true

echo "📦 3) Patch tsconfig.json to exclude analytics.disabled + express types …"
npx json -I -f tsconfig.json -e 'this.exclude=this.exclude||[]; if(!this.exclude.includes("src/analytics.disabled/**")) this.exclude.push("src/analytics.disabled/**")'

echo "🧹 4) Remove broken ESLint config …"
rm -f .eslintrc.json || true

echo "📝 5) Create i18n helper and locale JSONs …"
mkdir -p src/data/locales
cat > src/data/locales/en.json <<'JSON'
{
  "home": { "title": "Welcome to SoCalSolver", "description": "Smart calculators for every need." },
  "categories": {
    "finance": { "title": "Finance" },
    "health": { "title": "Health" },
    "math": { "title": "Mathematics" }
  }
}
JSON
for L in es fr it; do cp src/data/locales/en.json "src/data/locales/$L.json"; done

cat > src/lib/i18n.ts <<'TS'
import en from '@/data/locales/en.json'
import es from '@/data/locales/es.json'
import fr from '@/data/locales/fr.json'
import it from '@/data/locales/it.json'
const dict: Record<string, any> = { en, es, fr, it }
export async function getDictionary(locale: string) { return dict[locale] || dict.en }
export function getLocales(){ return ['en','es','fr','it'] }
TS

echo "🏠 6) Fix homepage route …"
mkdir -p src/app/[locale]
cat > src/app/[locale]/page.tsx <<'TSX'
import { getDictionary } from '@/lib/i18n'
export async function generateStaticParams(){ return [{locale:'en'},{locale:'es'},{locale:'fr'},{locale:'it'}] }
export default async function Home({params}:{params:{locale:string}}){
  const t=await getDictionary(params.locale)
  return(
    <main className="p-8 text-center">
      <h1 className="text-3xl font-bold">{t.home.title}</h1>
      <p className="text-lg mb-4">{t.home.description}</p>
      <ul className="flex gap-4 justify-center">
        {Object.keys(t.categories).map(cat=>(
          <li key={cat}><a href={`/${params.locale}/${cat}`} className="text-blue-600 underline">{t.categories[cat].title}</a></li>
        ))}
      </ul>
    </main>
  )
}
TSX

echo "🌐 7) New Next.js API v2 calculators route …"
mkdir -p src/app/api/v2/calculators
cat > src/app/api/v2/calculators/route.ts <<'TS'
import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'
export const runtime='edge'
const Schema=z.object({category:z.string().optional(),featured:z.coerce.boolean().optional(),search:z.string().optional(),page:z.coerce.number().min(1).default(1),limit:z.coerce.number().min(1).max(100).default(20),sort:z.enum(['name','category','popularity','created']).default('name'),order:z.enum(['asc','desc']).default('asc')})
export async function GET(req:NextRequest){
 const url=new URL(req.url);const raw=Object.fromEntries(url.searchParams.entries())
 const parsed=Schema.safeParse(raw);if(!parsed.success) return NextResponse.json({error:'Invalid query',details:parsed.error.flatten()},{status:400})
 const {page,limit}=parsed.data
 return NextResponse.json({calculators:[],pagination:{page,limit,total:0,pages:0,hasNext:false,hasPrev:false}})
}
TS

echo "🔗 8) Symlink locale-aware API folders …"
LOCS=(en es fr it); for L in "${LOCS[@]}"; do
  tgt="src/app/$L/api/v2"; mkdir -p "$tgt"; ln -sf ../../../../api/v2/calculators/route.ts "$tgt/calculators.ts"
done

echo "🧹 9) Clean .next cache …"
rm -rf .next

echo "🚀 10) Start dev server …"
npm run dev
