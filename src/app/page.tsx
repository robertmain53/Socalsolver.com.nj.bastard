import { headers } from 'next/headers'
import { redirect } from 'next/navigation'

const supportedLocales = ['en', 'es', 'fr', 'it']
const fallbackLocale = 'en'

export default function RootRedirect() {
  const headersList = headers()
  const acceptLang = headersList.get('accept-language') || ''
  const matched = supportedLocales.find(locale =>
    acceptLang.toLowerCase().startsWith(locale)
  )

  redirect(`/${matched || fallbackLocale}`)
}
