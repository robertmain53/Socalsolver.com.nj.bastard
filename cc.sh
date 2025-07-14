#!/bin/bash
set -euo pipefail


# Ensure globals.css exists
mkdir -p src/app && touch src/app/globals.css
echo -e "@tailwind base;\n@tailwind components;\n@tailwind utilities;" > src/app/globals.css

# Add layout.tsx for locale-aware layout
cat > src/app/[locale]/layout.tsx <<'EOF'
import { ReactNode } from 'react'
import '../../globals.css'

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
EOF

# Add fallback layout.tsx at root
cat > src/app/layout.tsx <<'EOF'
import './globals.css'
import { ReactNode } from 'react'

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
EOF

# Add locale-aware homepage handler
cat > src/app/[locale]/page.tsx <<'EOF'
import { getDictionary } from '@/lib/i18n'
import { getLocale } from '@/lib/locale'
import Link from 'next/link'

export default async function Home({ params }: { params: { locale: string } }) {
  const locale = getLocale(params.locale)
  const t = await getDictionary(locale)
  return (
    <main className="p-8 max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-4">{t.home.title}</h1>
      <p className="text-lg mb-6">{t.home.description}</p>
      <ul className="grid gap-2">
        {['finance', 'health', 'math'].map(cat => (
          <li key={cat}>
            <Link href={`/${locale}/${cat}`} className="text-blue-600 underline">
              {t.categories?.[cat]?.title || cat}
            </Link>
          </li>
        ))}
      </ul>
    </main>
  )
}
EOF

# Add dummy i18n library
mkdir -p src/lib
cat > src/lib/i18n.ts <<'EOF'
import en from '@/data/locales/en.json'
import es from '@/data/locales/es.json'
import fr from '@/data/locales/fr.json'
import it from '@/data/locales/it.json'

const dictionaries: Record<string, any> = { en, es, fr, it }

export async function getDictionary(locale: string) {
  return dictionaries[locale] || dictionaries.en
}
EOF

cat > src/lib/locale.ts <<'EOF'
export function getLocale(loc: string): string {
  const supported = ['en', 'es', 'fr', 'it']
  return supported.includes(loc) ? loc : 'en'
}
EOF

# Create missing locale files
mkdir -p src/data/locales
for lang in en es fr it; do
cat > src/data/locales/$lang.json <<EOF
{
  "home": {
    "title": "Welcome to SoCalSolver (${lang})",
    "description": "Smart calculators for every need."
  },
  "categories": {
    "finance": { "title": "Finance" },
    "health": { "title": "Health" },
    "math": { "title": "Mathematics" }
  }
}
EOF
done

# Update next.config.js for i18n
sed -i '/module.exports *= *{ */a\
  i18n: { locales: ["en", "es", "fr", "it"], defaultLocale: "en", localeDetection: false },
' next.config.js || true

# Remove Express and legacy route
rm -f src/api/v2/calculators.ts src/api/router.ts
mkdir -p src/api/v2 && echo "// Removed Express route" > src/api/v2/calculators.ts

# Patch page.tsx at root to redirect
cat > src/app/page.tsx <<'EOF'
import { redirect } from 'next/navigation'
export default function Home() {
  redirect('/en')
}
EOF

echo "✅ Patch complete. Run:"
echo " npm install && npm run dev"
