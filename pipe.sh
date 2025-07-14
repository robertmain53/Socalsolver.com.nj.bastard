#!/bin/bash
set -euo pipefail

# 1. Clean up any old locale-specific routes and ensure the dynamic [locale] structure exists
echo "🗑️ Removing any hard-coded locale directories (en, es, fr, it) if they exist..."
for L in en es fr it; do
  [ -d "src/app/$L" ] && rm -rf "src/app/$L"
done
echo "✅ Old locale directories removed (if any)."

echo "📁 Setting up dynamic [locale] route directory..."
mkdir -p src/app/[locale]
# Create a fallback root page that will delegate to the locale-specific homepage
cat > src/app/page.tsx <<'EOF'
export { default } from './[locale]/page';
EOF
echo "✅ Created src/app/page.tsx for index fallback."

# 2. Create/overwrite the localized homepage component 
# This page will serve /en, /es, /it, /fr routes (using the locale param).
echo "🌐 Creating localized homepage at src/app/[locale]/page.tsx ..."
cat > src/app/[locale]/page.tsx <<'EOF'
import { getDictionary } from '@/lib/i18n';
export default async function LocaleHome({ params }: { params: { locale: string } }) {
  const locale = params.locale || 'en';
  const t = await getDictionary(locale);
  return (
    <main className="p-8 max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-4">{t.home?.title || 'Welcome to SoCalSolver'}</h1>
      <p className="text-lg mb-6">{t.home?.description || 'Smart calculators for every need.'}</p>
    </main>
  );
}
EOF
echo "✅ Localized homepage component created."

# 3. Set up middleware for locale-aware routing and redirects
# - Redirects root "/" to "/en"
# - Redirects any path missing a locale prefix (except /api, /admin, static files) to the English version
echo "🔀 Configuring middleware for locale redirects..."
cat > middleware.ts <<'EOF'
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
EOF
echo "✅ Middleware implemented (locale-aware routing with exceptions for /api and /admin)."

# 4. Ensure translation JSON files exist for all locales
echo "🌐 Ensuring locale translation files are in place..."
mkdir -p src/data/locales
if [ ! -f "src/data/locales/en.json" ]; then
  cat > src/data/locales/en.json <<'EOF'
{
  "home": {
    "title": "Welcome to SoCalSolver",
    "description": "Smart calculators for every need."
  },
  "categories": {
    /* Add category name translations here (e.g., "finance": { "title": "Finance" }, etc.) */
  }
}
EOF
  echo "  - Created src/data/locales/en.json (default English strings)."
fi
for lang in es fr it; do
  if [ ! -f "src/data/locales/$lang.json" ]; then
    cp src/data/locales/en.json "src/data/locales/$lang.json"
    echo "  - Created placeholder src/data/locales/$lang.json (copy of English)."
  fi
done
echo "✅ Locale JSON files ready. (You may later update these with actual translations or run the translation script.)"

# 5. Remove duplicate or conflicting routes (unprefixed category/calculator pages) to avoid 404s and loops
echo "🗑️ Cleaning up old routing structure..."
# Remove the obsolete non-localized category pages directory if it exists
[ -d "src/app/categories" ] && rm -rf src/app/categories && echo "  - Removed src/app/categories (unprefixed category routes)."
# (Keeping src/app/calculators for reference, but it will be overridden by localized routes below)
echo "✅ Old unlocalized routes removed as needed."

# 6. Create localized "calculators" index page under each locale
# This will be accessible at /en/calculators, /es/calculators, etc., listing all categories/calculators.
echo "📝 Creating localized calculators index page..."
mkdir -p src/app/[locale]/calculators
cat > src/app/[locale]/calculators/page.tsx <<'EOF'
export { default, metadata } from '@/app/calculators/page';
EOF
echo "✅ Created src/app/[locale]/calculators/page.tsx (reusing /calculators page content for each locale)."

# 7. Implement locale-aware header for navigation (brand and Home link)
echo "💡 Adding a shared Header component with locale-aware Home link..."
mkdir -p src/components/layout
cat > src/components/layout/Header.tsx <<'EOF'
'use client';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

const labels: Record<string, string> = { en: 'Home', fr: 'Accueil', es: 'Inicio', it: 'Home' };

export default function Header() {
  const path = usePathname();
  const locale = path.split('/')[1] || 'en';
  return (
    <header className="py-4 border-b flex gap-6 px-4">
      <Link href={`/${locale}`} className="font-bold text-lg">SoCalSolver</Link>
      <Link href={`/${locale}`} className="text-sm font-medium hover:text-blue-600">
        {labels[locale] || 'Home'}
      </Link>
    </header>
  );
}
EOF
echo "✅ Header component created."

# 8. Insert Header (and Footer if desired) into the Root layout for all pages
# This ensures the navigation links appear on every page.
echo "🔗 Injecting Header component into the root layout..."
# Import Header in src/app/layout.tsx and include in the JSX
sed -i "s|import { ReactNode } from 'react'|import { ReactNode } from 'react'\nimport Header from '@/components/layout/Header'|g" src/app/layout.tsx
sed -i "s|<body>|<body>\\n        <Header />\\n        |g" src/app/layout.tsx
echo "✅ Header added to src/app/layout.tsx."

# 9. Update breadcrumb components for locale-aware links (Home, Calculators, category links)
echo "🔄 Updating breadcrumb components with locale-aware links..."
# CategoryBreadcrumbs component
cat > src/components/calculators/CategoryBreadcrumbs.tsx <<'EOF'
import Link from 'next/link';
import { ChevronRightIcon } from 'lucide-react';

interface Props {
  category: string;
  locale: string;
}

export default function CategoryBreadcrumbs({ category, locale }: Props) {
  return (
    <nav className="flex mb-6" aria-label="Breadcrumb">
      <ol className="inline-flex items-center space-x-1 md:space-x-3">
        <li className="inline-flex items-center">
          <Link href={`/${locale}`} className="inline-flex items-center text-sm font-medium text-gray-700 hover:text-blue-600">Home</Link>
        </li>
        <li>
          <div className="flex items-center">
            <ChevronRightIcon className="w-4 h-4 text-gray-400" />
            <Link href={`/${locale}/calculators`} className="inline-flex items-center text-sm font-medium text-gray-700 hover:text-blue-600 ml-1 md:ml-2">Calculators</Link>
          </div>
        </li>
        <li aria-current="page">
          <div className="flex items-center">
            <ChevronRightIcon className="w-4 h-4 text-gray-400" />
            <span className="inline-flex items-center text-sm font-medium text-gray-500 ml-1 md:ml-2">{category}</span>
          </div>
        </li>
      </ol>
    </nav>
  );
}
EOF

# CalculatorBreadcrumbs component
cat > src/components/calculators/CalculatorBreadcrumbs.tsx <<'EOF'
import Link from 'next/link';
import { ChevronRightIcon } from 'lucide-react';
import type { CalculatorSEO } from '@/lib/seo';

interface Props {
  calculator: CalculatorSEO;
  locale: string;
}

export default function CalculatorBreadcrumbs({ calculator, locale }: Props) {
  // Derive category slug and names for breadcrumb (if available)
  const categorySlug = (calculator as any).category || calculator?.seo?.category;
  const categoryName = (calculator as any).categoryName || calculator?.seo?.category || 'Category';
  const calcTitle = (calculator as any).title || (calculator as any).name || calculator?.seo?.title || calculator?.seo?.name || calculator?.seo?.slug || 'Calculator';
  return (
    <nav className="flex mb-6" aria-label="Breadcrumb">
      <ol className="inline-flex items-center space-x-1 md:space-x-3">
        <li className="inline-flex items-center">
          <Link href={`/${locale}`} className="inline-flex items-center text-sm font-medium text-gray-700 hover:text-blue-600">Home</Link>
        </li>
        <li>
          <div className="flex items-center">
            <ChevronRightIcon className="w-4 h-4 text-gray-400" />
            <Link href={`/${locale}/calculators`} className="inline-flex items-center text-sm font-medium text-gray-700 hover:text-blue-600 ml-1 md:ml-2">Calculators</Link>
          </div>
        </li>
        {categorySlug && (
          <li>
            <div className="flex items-center">
              <ChevronRightIcon className="w-4 h-4 text-gray-400" />
              <Link href={`/${locale}/${categorySlug}`} className="inline-flex items-center text-sm font-medium text-gray-700 hover:text-blue-600 ml-1 md:ml-2">{categoryName}</Link>
            </div>
          </li>
        )}
        <li aria-current="page">
          <div className="flex items-center">
            <ChevronRightIcon className="w-4 h-4 text-gray-400" />
            <span className="inline-flex items-center text-sm font-medium text-gray-500 ml-1 md:ml-2">{calcTitle}</span>
          </div>
        </li>
      </ol>
    </nav>
  );
}
EOF
echo "✅ Breadcrumb components updated with locale-aware links."

# 10. (Optional) Integrate breadcrumbs on pages (if not already integrated)
# For example, on category and calculator pages, ensure the breadcrumb components receive the locale and render.
# This step may require manual insertion in the page components if not present.
echo "ℹ️ Note: Ensure to use the updated <CategoryBreadcrumbs locale={...} /> and <CalculatorBreadcrumbs locale={...} /> in the respective pages."

# 11. Implement hreflang tags in HTML head for SEO
echo "🌍 Adding hreflang <link> tags for SEO in the HTML head..."
cat > src/app/[locale]/head.tsx <<'EOF'
'use client';
import { usePathname } from 'next/navigation';
const locales = ['en', 'fr', 'es', 'it'];
const baseUrl = 'https://socalsolver.com';  // Update to your production domain if different
export default function Head() {
  const pathname = usePathname() || '';
  // Remove locale segment from the path
  const segments = pathname.split('/').filter(Boolean);
  segments.shift(); // drop the locale (first segment)
  const pathWithoutLocale = segments.length ? `/${segments.join('/')}` : '';
  return (
    <>
      {locales.map((loc) => (
        <link 
          key={loc}
          rel="alternate"
          hrefLang={loc}
          href={`${baseUrl}/${loc}${pathWithoutLocale}`} 
        />
      ))}
      {/* x-default points to English as the default language */}
      <link rel="alternate" hrefLang="x-default" href={`${baseUrl}/en${pathWithoutLocale}`} />
    </>
  );
}
EOF
echo "✅ Hreflang tags head component added at src/app/[locale]/head.tsx."

echo ""
echo "🎉 All done! The locale-aware routing, links, and SEO tags have been configured. You can now run 'npm run dev' to test the application."
