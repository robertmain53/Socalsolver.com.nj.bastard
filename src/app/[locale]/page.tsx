// src/app/[locale]/page.tsx
import { getDictionary } from '@/lib/i18n'
import Link from 'next/link'

export default async function Home({ params }: { params: { locale: string } }) {
  const locale = params.locale
  const t = await getDictionary(locale)

  return (
    <main className="p-8 text-center">
      <h1 className="text-3xl font-bold">{t.home.title}</h1>
      <p className="text-lg mb-4">{t.home.description}</p>
      <ul className="flex gap-4 justify-center">
        {Object.keys(t.categories).map(cat => (
          <li key={cat}>
            <Link href={`/${locale}/${cat}`} className="text-blue-600 underline">
              {t.categories[cat].title}
            </Link>
          </li>
        ))}
      </ul>
    </main>
  )
}

