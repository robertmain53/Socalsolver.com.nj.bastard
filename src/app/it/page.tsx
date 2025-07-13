import { getDictionary } from '@/lib/i18n'
import Link from 'next/link'

export default async function Home() {
  const t = await getDictionary('it')
  return (
    <main className="p-8 max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-4">{t.home.title}</h1>
      <p className="text-lg mb-6">{t.home.description}</p>
      <ul className="grid gap-2">
        {['finance', 'health', 'math'].map(cat => (
          <li key={cat}>
            <Link href="/it/${cat}" className="text-blue-600 underline">
              {t.categories[cat]?.title || cat}
            </Link>
          </li>
        ))}
      </ul>
    </main>
  )
}
