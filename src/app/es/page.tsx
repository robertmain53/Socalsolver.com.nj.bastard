import { getDictionary } from '@/lib/i18n'
import Link from 'next/link'
import { getLocale } from '@/lib/locale'

export default async function Home() {
  const locale = getLocale()
  const t = await getDictionary(locale)
  return (
    <main className="p-8">
      <h1>{t?.home?.title || 'Welcome'}</h1>
      <p>{t?.home?.description || 'Localized calculators at your service.'}</p>
      <ul>
        {Object.keys(t?.categories || {}).map(cat => (
          <li key={cat}>
            <Link href={`/${locale}/${cat}`}>{t.categories[cat]?.title || cat}</Link>
          </li>
        ))}
      </ul>
    </main>
  )
}
