import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const PUBLIC_FILE = /\.(.*)$/;
const SUPPORTED_LOCALES = ['en', 'es', 'fr', 'it'];
const DEFAULT_LOCALE = 'en';

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  // Skip next internals, static files, API and admin
  if (
    pathname.startsWith('/_next') ||
    pathname.startsWith('/api') ||
    pathname.startsWith('/admin') ||
    PUBLIC_FILE.test(pathname)
  ) {
    return NextResponse.next();
  }

  // Extract first segment from path
  const segments = pathname.split('/').filter(Boolean);
  const firstSegment = segments[0];

  // Case 1: Root ("/") → redirect to /en
  if (pathname === '/') {
    return NextResponse.redirect(new URL(`/${DEFAULT_LOCALE}`, req.url));
  }

  // Case 2: Already has a valid locale → don't touch it
  if (SUPPORTED_LOCALES.includes(firstSegment)) {
    return NextResponse.next();
  }

  // Case 3: Any path without a valid locale → prepend default locale
  return NextResponse.redirect(new URL(`/${DEFAULT_LOCALE}${pathname}`, req.url));
}
