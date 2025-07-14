// src/app/[locale]/page.tsx
import { getDictionary } from '@/lib/i18n'
import { Locale } from '@/lib/i18n-config'

export default async function Home({ params }: { params: { locale: Locale } }) {
  const locale = params.locale || 'en'
  const t = await getDictionary(locale)

  return (
    <main className="p-8 max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-4">{t?.home?.title || 'Welcome'}</h1>
      <p className="text-lg mb-6">{t?.home?.description || 'Smart calculators for every need.'}</p>
    </main>
  )
}

