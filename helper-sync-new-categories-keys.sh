node - <<'JS'
const fs=require('fs')
const base=JSON.parse(fs.readFileSync('content/categories/en.json'))
;['es','fr','it'].forEach(l=>{
  const p=`content/categories/${l}.json`
  const tgt=fs.existsSync(p)?JSON.parse(fs.readFileSync(p)):{}
  fs.writeFileSync(p,JSON.stringify({...base,...tgt},null,2))
})
JS
