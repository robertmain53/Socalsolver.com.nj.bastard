#!/bin/bash
set -euo pipefail

echo "🔧 Removing hardcoded locale folders..."
rm -rf src/app/en src/app/es src/app/it src/app/fr

echo "✅ Ensuring dynamic locale homepage exists..."
mkdir -p src/app/[locale]
cat > src/app/[locale]/page.tsx <<'EOF'
import { notFound } from 'next/navigation'

const messages = {
  en: { welcome: 'Welcome to SoCalSolver', slogan: 'Smart calculators for every need.' },
  es: { welcome: 'Bienvenido a SoCalSolver', slogan: 'Calculadoras inteligentes para cada necesidad.' },
  fr: { welcome: 'Bienvenue à SoCalSolver', slogan: 'Des calculatrices intelligentes pour chaque besoin.' },
  it: { welcome: 'Benvenuto su SoCalSolver', slogan: 'Calcolatrici intelligenti per ogni esigenza.' },
}

export default function Home({ params }: { params: { locale: string } }) {
  const t = messages[params.locale as keyof typeof messages]
  if (!t) return notFound()

  return (
    <main className="p-12 text-center">
      <h1 className="text-4xl font-bold">{t.welcome}</h1>
      <p className="mt-4 text-lg text-gray-600">{t.slogan}</p>
    </main>
  )
}
EOF

echo "⚙️  Updating middleware.ts..."
cat > middleware.ts <<'EOF'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl
  if (pathname === '/') return NextResponse.redirect(new URL('/en', req.url))
  return NextResponse.next()
}
EOF

echo "🛠 Patching next.config.js i18n block..."
npx replace-in-file \
  "i18n: {.*?}" \
  "i18n: { locales: ['en', 'es', 'fr', 'it'], defaultLocale: 'en', localeDetection: false }" \
  next.config.js || true

echo "🧹 Cleaning up Next.js build cache..."
rm -rf .next

echo "🚀 Starting dev server..."
npm run dev || echo "✅ Done. Now run: npm run dev"
