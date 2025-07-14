import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const PUBLIC_FILE = /\.(.*)$/;
const supportedLocales = ['en', 'es', 'fr', 'it'];

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;
  // Skip Next.js internal routes, API routes, admin routes, and static files
  if (
    pathname.startsWith('/_next') || pathname.startsWith('/api') ||
    pathname.startsWith('/admin') || PUBLIC_FILE.test(pathname)
  ) {
    return NextResponse.next();
  }
  // Redirect root URL ("/") to default locale ("/en")
  if (pathname === '/') {
    return NextResponse.redirect(new URL('/en', req.url));
  }
  // If the first URL segment is not a supported locale, prepend "/en"
  const firstSegment = pathname.split('/')[1];
  if (!supportedLocales.includes(firstSegment)) {
    return NextResponse.redirect(new URL(`/en${pathname}`, req.url));
  }
  // Otherwise, the locale is present and supported – continue as normal
  return NextResponse.next();
}
