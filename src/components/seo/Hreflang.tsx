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
