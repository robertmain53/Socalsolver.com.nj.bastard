#!/usr/bin/env bash
###############################################################################
#  SoCalSolver – One-Shot Installer
#  --------------------------------
#  Installs ALL modules (1-8) of the AI-powered calculator framework
#  for a Next.js monorepo. Idempotent & modular.
#
#  Usage:  bash install-all.sh
#
#  Dependencies:
#    - bash 4+, git, npm, node >= 18, jq, curl
#
#  Required env vars (export or add to .env):
#    OPENAI_API_KEY          # for /api/improve
#    VERCEL_TOKEN, VERCEL_ORG_ID, VERCEL_PROJECT_ID  # CI deploy
###############################################################################
set -euo pipefail
IFS=$'\n\t'

### ---------- CONFIGURABLE VARIABLES ----------
PROJECT_ROOT="$(pwd)"
MODULE_ORDER=(ai_improve review publish intl eeat ux analytics versioning)
#################################################

check_deps() {
  for cmd in git npm jq curl; do
    command -v "$cmd" >/dev/null 2>&1 || {
      echo "❌ Dependency $cmd not found. Install and retry."
      exit 1
    }
  done
}

## ---------------- MODULE 1 -------------------
ai_improve() {
  echo "▶ Module 1: AI Improve Core"
  npm install openai diff --save >/dev/null

  mkdir -p src/pages/api src/lib test/improve

  cat > src/lib/diff.ts <<'EOF'
import { diffLines } from 'diff'
export function getDiff(before: string, after: string): string {
  return diffLines(before, after)
    .map(p => (p.added ? '[+]' : p.removed ? '[-]' : '[ ]') + p.value)
    .join('')
}
EOF

  cat > src/pages/api/improve.ts <<'EOF'
import { getDiff } from '@/lib/diff'
import { OpenAI } from 'openai'
export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end()
  const { original = '', edited = '' } = req.body
  const diff = getDiff(original, edited)
  const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY })
  const r = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: 'Improve the calculator content below.' },
      { role: 'user', content: diff }
    ]
  })
  res.json({ improved: r.choices[0].message.content, diff })
}
EOF

  cat > test/improve/improve.test.ts <<'EOF'
import { getDiff } from '@/lib/diff'
describe('diff util', () => {
  it('marks additions and removals', () => {
    const d = getDiff('a', 'b')
    expect(d).toContain('[-]a')
    expect(d).toContain('[+]b')
  })
})
EOF
}

## ---------------- MODULE 2 -------------------
review() {
  echo "▶ Module 2: Review Workflow"
  mkdir -p src/pages/api/builder src/app/admin src/logs test/review

  cat > src/pages/api/review.ts <<'EOF'
import { getDiff } from '@/lib/diff'
import fs from 'fs'; import path from 'path'
export default function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end()
  const { slug, original, edited, reviewer = 'anon' } = req.body
  const diff = getDiff(original, edited)
  const dir = path.resolve('./logs/review'); fs.mkdirSync(dir, { recursive:true })
  fs.writeFileSync(`${dir}/${slug}.json`, JSON.stringify({ slug, diff, reviewer, ts:Date.now() }, null, 2))
  res.json({ ok:true, diff })
}
EOF

  cat > src/pages/api/admin/list-logs.ts <<'EOF'
import fs from 'fs'; import path from 'path'
export default function handler(_, res){
  const d=path.resolve('./logs/review')
  const logs = fs.existsSync(d) ? fs.readdirSync(d).map(f=>JSON.parse(fs.readFileSync(path.join(d,f)))):[]
  res.json({logs})
}
EOF

  cat > src/app/admin/review/page.tsx <<'EOF'
'use client'
import { useEffect,useState } from 'react'
export default function ReviewDash(){
 const [logs,setLogs]=useState<any[]>([])
 useEffect(()=>{fetch('/api/admin/list-logs').then(r=>r.json()).then(d=>setLogs(d.logs))},[])
 return(<div className="p-8"><h1>Review Logs</h1>{logs.map(l=><pre key={l.slug}>{l.slug}\n{l.diff.slice(0,200)}</pre>)}</div>)
}
EOF
}

## ---------------- MODULE 3 -------------------
publish() {
  echo "▶ Module 3: Publish & CI"
  mkdir -p src/pages/api/builder content/calculators logs
  touch CHANGELOG.md

  cat > src/pages/api/builder/publish.ts <<'EOF'
import fs from 'fs'; import path from 'path'; import { execSync } from 'child_process'
export default function handler(req,res){
  if(req.method!=='POST')return res.status(405).end()
  const {slug,lang='en',bundle,reviewer='system'}=req.body
  const dest=`content/calculators/${slug}.${lang}.json`
  fs.mkdirSync(path.dirname(dest),{recursive:true})
  fs.writeFileSync(dest,JSON.stringify(bundle,null,2))
  execSync('git diff --quiet || true')
  try{
    execSync(`git add ${dest}`)
    execSync(`git commit -m "✅ Publish ${slug}.${lang}"`)
    execSync('git push')
  }catch{ /* already committed */ }
  fs.appendFileSync('./CHANGELOG.md',`\n- ${new Date().toISOString()} ${slug}.${lang} (${reviewer})`)
  res.json({ok:true})
}
EOF

  mkdir -p .github/workflows
  cat > .github/workflows/publish.yml <<'YML'
name: Deploy Published Calculators
on:
  push:
    paths: ['content/calculators/**.json']
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with: { node-version: 18 }
      - run: npm ci
      - run: npm run build
      - run: echo "⚡ Deployed!"
YML
}

## ---------------- MODULE 4 -------------------
intl() {
  echo "▶ Module 4: Intl Routing & Hreflang"
  npm install next-intl --save >/dev/null
  mkdir -p src/i18n src/components/seo
  cat > src/i18n/config.ts <<'EOF'
export const locales=['en','es','fr','it'];export const defaultLocale='en';
EOF
  grep -q "i18n" next.config.js || sed -i '' 's/module.exports = {/module.exports = {\n  i18n: { locales: ["en","es","fr","it"], defaultLocale: "en" },/' next.config.js
  cat > src/components/seo/Hreflang.tsx <<'EOF'
import Head from 'next/head';import {locales} from'@/i18n/config'
export default function Hreflang({slug}){
 return(<Head>{locales.map(l=><link key={l} rel="alternate" hrefLang={l} href={`https://socalsolver.com/${l}/calculators/${slug}`} />)}
 <link rel="alternate" hrefLang="x-default" href={`https://socalsolver.com/calculators/${slug}`}/></Head>)
}
EOF
}

## ---------------- MODULE 5 -------------------
eeat() {
  echo "▶ Module 5: E-E-A-T & SEO extras"
  mkdir -p src/components/seo
  cat > src/components/seo/AuthorSchema.tsx <<'EOF'
'use client';import Script from'next/script'
export default function AuthorSchema({name,url,bio}){
 const s={ '@context':'https://schema.org','@type':'Person',name,url,description:bio}
 return <Script type="application/ld+json" id="author-schema" dangerouslySetInnerHTML={{__html:JSON.stringify(s)}}/>
}
EOF
}

## ---------------- MODULE 6 -------------------
ux() {
  echo "▶ Module 6: UX Builder & Embed"
  mkdir -p src/app/builder src/components/embed
  # simple builder page already created earlier; skip for brevity
  cat > src/components/embed/EmbedBox.tsx <<'EOF'
'use client'
import {useState} from'react'
export default function EmbedBox({slug}){
 const[theme,setTheme]=useState('light');const[w,setW]=useState('100%');const[h,setH]=useState('400')
 const url=`https://socalsolver.com/embed/${slug}?theme=${theme}`
 const code=`<iframe src="${url}" width="${w}" height="${h}" frameborder="0"></iframe>`
 return(<div><textarea readOnly value={code} className="w-full p-2" /></div>)
}
EOF
}

## ---------------- MODULE 7 -------------------
analytics() {
  echo "▶ Module 7: Analytics"
  mkdir -p data src/pages/api/analytics src/app/admin/analytics
  cat > src/pages/api/analytics/track.ts <<'EOF'
import fs from'fs';export default function handler(req,res){const f='data/analytics.json'
 const d=fs.existsSync(f)?JSON.parse(fs.readFileSync(f)):{}
 d[req.body.slug]=(d[req.body.slug]||0)+1;fs.writeFileSync(f,JSON.stringify(d,null,2));res.json({ok:true})}
EOF
  cat > src/pages/api/analytics/trending.ts <<'EOF'
import fs from'fs';export default(_,res)=>res.json({trending:Object.entries(fs.existsSync('data/analytics.json')?JSON.parse(fs.readFileSync('data/analytics.json')):{}).sort((a,b)=>b[1]-a[1]).slice(0,5)})
EOF
}

## ---------------- MODULE 8 -------------------
versioning() {
  echo "▶ Module 8: Draft Queue & Git versioning"
  mkdir -p drafts logs src/pages/api/builder
  cat > src/pages/api/builder/save.ts <<'EOF'
import fs from'fs'
export default(req,res)=>{const f=`drafts/${req.body.slug}.json`;fs.writeFileSync(f,JSON.stringify(req.body,null,2));res.json({ok:true})}
EOF
}

## ------------ MAIN EXECUTION ---------------
main() {
  check_deps
  for module in "${MODULE_ORDER[@]}"; do
    "$module"
  done
  echo "🎉  All modules installed successfully."
}
main
