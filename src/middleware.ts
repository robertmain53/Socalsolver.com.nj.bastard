// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

const PUBLIC_FILE = /\.(.*)$/
const locales = ['en', 'it', 'fr', 'es']
const defaultLocale = 'en'

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Skip static files and API
  if (
    PUBLIC_FILE.test(pathname) ||
    pathname.startsWith('/api') ||
    locales.some((locale) => pathname.startsWith(`/${locale}`))
  ) {
    return
  }

  // Redirect root `/` to default locale `/en`
  if (pathname === '/') {
    const url = request.nextUrl.clone()
    url.pathname = `/${defaultLocale}`
    return NextResponse.redirect(url)
  }

  return
}
