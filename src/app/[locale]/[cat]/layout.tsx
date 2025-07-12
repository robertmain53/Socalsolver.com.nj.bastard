// src/app/[locale]/[cat]/layout.tsx
import { ReactNode } from 'react'
import { getCategoryData } from '@/lib/loadCategory'
import { Metadata } from 'next'

export async function generateMetadata({ params }): Promise<Metadata> {
  const data = await getCategoryData(params.locale)
  const cat = data[params.cat] || {}
  return {
    title: cat.metaTitle || cat.title,
    description: cat.metaDescription || cat.description,
    robots: cat.noindex ? 'noindex' : 'index,follow',
    alternates: {
      languages: {
        'x-default': `/calculator/${params.cat}`,
        en: `/en/${params.cat}`,
        es: `/es/${params.cat}`,
        fr: `/fr/${params.cat}`,
        it: `/it/${params.cat}`,
      }
    }
  }
}

export default function CategoryLayout({ children }: { children: ReactNode }) {
  return <>{children}</>
}
