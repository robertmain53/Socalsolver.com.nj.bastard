import { headers } from 'next/headers'

export function getLocale() {
  const headersList = headers()
  const pathname = headersList.get('x-invoke-path') || '/'
  const match = pathname.match(/^\/(en|es|fr|it)\b/)
  return match?.[1] || 'en'
}
