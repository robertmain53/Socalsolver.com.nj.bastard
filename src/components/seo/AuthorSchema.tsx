'use client';import Script from'next/script'
export default function AuthorSchema({name,url,bio}:{name:string,url:string,bio:string}){
 const s={ '@context':'https://schema.org','@type':'Person',name,url,description:bio}
 return <Script id="author-json" type="application/ld+json"
   dangerouslySetInnerHTML={{__html:JSON.stringify(s)}}/>
}
