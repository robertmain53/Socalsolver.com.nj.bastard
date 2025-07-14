import { getDictionary } from '@/lib/i18n'
import { getLocale } from '@/lib/locale'

export default async function Home({ params }: { params: { locale: string } }) {
  const locale = params.locale || 'en'
  const t = await getDictionary(locale)

  return (
    <main className="p-8">
      <h1>{t.home.title}</h1>
      <p>{t.home.description}</p>
    </main>
  )
}

