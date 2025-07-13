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
