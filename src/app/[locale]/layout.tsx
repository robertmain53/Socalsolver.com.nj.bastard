import { ReactNode } from 'react'


export default function LocaleLayout({
  children,
  params: { locale }
}: {
  children: ReactNode
  params: { locale: string }
}) {
  return (
    <html lang={locale}>
      <body>{children}</body>
    </html>
  )
}
