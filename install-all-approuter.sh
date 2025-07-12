#!/usr/bin/env bash
# install-all-approuter.sh
# One command to install ALL SoCalSolver modules using Next.js App Router APIs only
set -euo pipefail
IFS=$'\n\t'
req() { command -v "$1" >/dev/null || { echo "❌ $1 required"; exit 1; }; }
for c in git npm jq curl; do req "$c"; done

root="$(pwd)"

# ----- helper ----------
write () { mkdir -p "$(dirname "$1")"; cat > "$1"; }

# ---------- Module 1 – AI Improve (app router) ----------
npm install openai diff --save >/dev/null
write src/lib/diff.ts <<'TS'
import { diffLines } from 'diff'
export function getDiff(a:string,b:string){
 return diffLines(a,b).map(p=>(p.added?'[+]':p.removed?'[-]':'[ ]')+p.value).join('')
}
TS
write src/app/api/improve/route.ts <<'TS'
import { OpenAI } from 'openai'
import { getDiff } from '@/lib/diff'
export const runtime='edge'
export async function POST(req:Request){
 const {original='',edited=''} = await req.json()
 const diff = getDiff(original,edited)
 const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY })
 const r = await openai.chat.completions.create({
   model:'gpt-4o-mini',
   messages:[{role:'system',content:'Improve:'},{role:'user',content:diff}]
 })
 return Response.json({ improved:r.choices[0].message.content,diff })
}
TS

# ---------- Module 2 – Review ----------
write src/app/api/review/route.ts <<'TS'
import fs from'fs/promises'
import { getDiff } from '@/lib/diff'
export async function POST(req:Request){
 const {slug,original,edited,reviewer='anon'}=await req.json()
 const diff=getDiff(original,edited)
 await fs.mkdir('logs/review',{recursive:true})
 await fs.writeFile(`logs/review/${slug}.json`,JSON.stringify({slug,diff,reviewer,ts:Date.now()},null,2))
 return Response.json({ok:true})
}
TS
write src/app/api/admin/list-logs/route.ts <<'TS'
import fs from'fs/promises'
export const runtime='edge'
export async function GET(){
 const files = await fs.readdir('logs/review').catch(()=>[])
 const logs = await Promise.all(files.map(f=>fs.readFile(`logs/review/${f}`,'utf8').then(JSON.parse)))
 return Response.json({logs})
}
TS

# ---------- Module 3 – Publish ----------
touch CHANGELOG.md
write src/app/api/builder/publish/route.ts <<'TS'
import fs from'fs/promises'
import { exec } from'child_process'
import { promisify } from'node:util'
const sh=promisify(exec)
export async function POST(req:Request){
 const {slug,lang='en',bundle,reviewer='sys'}=await req.json()
 const dest=`content/calculators/${slug}.${lang}.json`
 await fs.mkdir('content/calculators',{recursive:true})
 await fs.writeFile(dest,JSON.stringify(bundle,null,2))
 try{await sh(`git add ${dest} && git commit -m "✅ Publish ${slug}.${lang}" && git push`)}catch{}
 await fs.appendFile('CHANGELOG.md',`\n- ${new Date().toISOString()} ${slug}.${lang} (${reviewer})`)
 return Response.json({ok:true})
}
TS
mkdir -p .github/workflows
write .github/workflows/publish.yml <<'YML'
name: Deploy Published Calculators
on: { push: { paths: ['content/calculators/**.json'] } }
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with: { node-version: 18 }
      - run: npm ci && npm run build
YML

# ---------- Module 4 – Intl / hreflang ----------
npm install next-intl --save >/dev/null
write src/i18n/config.ts <<'TS'
export const locales=['en','es','fr','it'] as const
export const defaultLocale='en'
TS
grep -q i18n next.config.js || \
sed -i.bak 's/module.exports = {/module.exports = {\n  i18n:{locales:["en","es","fr","it"],defaultLocale:"en"},/' next.config.js

# hreflang component
write src/components/seo/Hreflang.tsx <<'TSX'
import Head from'next/head'
import {locales} from'@/i18n/config'
export default function Hreflang({slug}:{slug:string}){
 return(<Head>
  {locales.map(l=><link key={l} rel="alternate" hrefLang={l}
    href={`https://socalsolver.com/${l}/calculators/${slug}`} />)}
  <link rel="alternate" hrefLang="x-default"
    href={`https://socalsolver.com/calculators/${slug}`} />
 </Head>)
}
TSX

# ---------- Module 5 – E-E-A-T Author schema ----------
write src/components/seo/AuthorSchema.tsx <<'TSX'
'use client';import Script from'next/script'
export default function AuthorSchema({name,url,bio}:{name:string,url:string,bio:string}){
 const s={ '@context':'https://schema.org','@type':'Person',name,url,description:bio}
 return <Script id="author-json" type="application/ld+json"
   dangerouslySetInnerHTML={{__html:JSON.stringify(s)}}/>
}
TSX

# ---------- Module 6 – Analytics ----------
mkdir -p data src/app/api/analytics
write src/app/api/analytics/track/route.ts <<'TS'
import fs from'fs/promises'
export async function POST(req:Request){
 const {slug}=await req.json()
 const f='data/analytics.json'
 let d:{}= {}
 try{d=JSON.parse(await fs.readFile(f,'utf8'))}catch{}
 d[slug]=(d[slug]||0)+1
 await fs.mkdir('data',{recursive:true});await fs.writeFile(f,JSON.stringify(d,null,2))
 return Response.json({ok:true})
}
TS

# ---------- Module 7 – Draft save ----------
mkdir -p drafts src/app/api/builder
write src/app/api/builder/save/route.ts <<'TS'
import fs from'fs/promises'
export async function POST(req:Request){
 const b=await req.json();await fs.writeFile(`drafts/${b.slug}.json`,JSON.stringify(b,null,2))
 return Response.json({ok:true})
}
TS

# ---------- Tailwind fix ----------
[ -f tailwind.config.js ] || echo 'module.exports={content:["src/**/*.{ts,tsx,mdx}"],theme:{extend:{}},plugins:[]}' > tailwind.config.js

echo "✅ App-Router installer finished."
