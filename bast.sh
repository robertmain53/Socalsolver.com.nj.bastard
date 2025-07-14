#!/bin/bash
set -euo pipefail

echo "🛠️ Fixing SoCalSolver platform..."

PROJECT_DIR="$(pwd)"
SRC_DIR="$PROJECT_DIR/src"
APP_DIR="$SRC_DIR/app"

# 1. 🧹 Cleanup problematic locales folder structure
echo "🧼 Removing broken per-locale folders..."
rm -rf "$APP_DIR/en" "$APP_DIR/it" "$APP_DIR/es" "$APP_DIR/fr"

# 2. 🌍 Create correct locale-aware routing structure
mkdir -p "$APP_DIR/[locale]"

cat > "$APP_DIR/[locale]/page.tsx" <<EOF
import { getDictionary } from '@/lib/i18n';
import { getLocale } from '@/lib/locale';
import Link from 'next/link';

export default async function Home({ params }: { params: { locale: string } }) {
  const locale = getLocale(params.locale);
  const t = await getDictionary(locale);

  return (
    <main className="p-8 max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-4">{t.home?.title || 'Welcome'}</h1>
      <p className="text-lg mb-6">{t.home?.description || 'Smart calculators'}</p>
      <ul className="grid gap-2">
        {['finance', 'health', 'math'].map(cat => (
          <li key={cat}>
            <Link href={\`/\${locale}/categories/\${cat}\`} className="text-blue-600 underline">
              {t.categories?.[cat]?.title || cat}
            </Link>
          </li>
        ))}
      </ul>
    </main>
  );
}
EOF

# 3. 🌐 Fix middleware for proper locale redirect detection
cat > "$SRC_DIR/middleware.ts" <<EOF
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

const PUBLIC_FILE = /\.(.*)$/
const locales = ['en', 'it', 'fr', 'es']
const defaultLocale = 'en'

function getLocaleFromPath(pathname: string) {
  const parts = pathname.split('/')
  return locales.includes(parts[1]) ? parts[1] : null
}

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl

  if (PUBLIC_FILE.test(pathname)) return

  const localeInPath = getLocaleFromPath(pathname)
  if (localeInPath) return

  const locale = req.headers.get('Accept-Language')?.split(',')[0].split('-')[0] || defaultLocale
  const redirectLocale = locales.includes(locale) ? locale : defaultLocale

  const url = req.nextUrl.clone()
  url.pathname = \`/\${redirectLocale}\${pathname}\`
  return NextResponse.redirect(url)
}

export const config = {
  matcher: ['/((?!api|_next|favicon.ico).*)'],
}
EOF

# 4. 📁 Patch globals.css to remove tailwind error
sed -i '/border-border/d' "$APP_DIR/globals.css" || true

# 5. 🌍 Regenerate locale JSON files
LOCALE_DIR="$SRC_DIR/data/locales"
mkdir -p "$LOCALE_DIR"

for lang in en es fr it; do
  cat > "$LOCALE_DIR/$lang.json" <<EOL
{
  "home": {
    "title": "Welcome to SoCalSolver",
    "description": "Smart calculators for every need"
  },
  "categories": {
    "finance": { "title": "Finance" },
    "health": { "title": "Health" },
    "math": { "title": "Math" }
  }
}
EOL
done

# 6. 🧠 Ensure category routing exists
mkdir -p "$APP_DIR/[locale]/categories/[cat]"

cat > "$APP_DIR/[locale]/categories/[cat]/page.tsx" <<EOF
export default function CategoryPage({ params }: { params: { locale: string, cat: string } }) {
  return (
    <main className="p-8 max-w-4xl mx-auto">
      <h1 className="text-3xl font-bold mb-4">Category: {params.cat}</h1>
      <p>More content coming soon for locale: {params.locale}</p>
    </main>
  );
}
EOF

# 7. ✅ Fix next.config.js
sed -i "s/module.exports = {/module.exports = {\n  i18n: { locales: ['en','es','fr','it'], defaultLocale: 'en', localeDetection: false },/" "$PROJECT_DIR/next.config.js" || true

# 8. 📦 Install missing deps
npm install

# 9. 🧹 Clean and rebuild
rm -rf .next
npm run build

echo "✅ Patch complete. Run with: npm run dev"
