// src/app/[locale]/layout.tsx
import { ReactNode } from 'react'
import { getLocales } from '@/lib/i18n'

export async function generateStaticParams() {
  const locales = getLocales()
  return locales.map(locale => ({ locale }))
}

export default function LocaleLayout({
  children,
  params,
}: {
  children: ReactNode
  params: { locale: string }
}) {
  return <html lang={params.locale}><body>{children}</body></html>
}

