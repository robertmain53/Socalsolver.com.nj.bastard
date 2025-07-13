#!/bin/bash
set -euo pipefail

echo "🧹 Cleaning .next cache (to avoid gzip rename errors)..."
rm -rf .next

echo "📁 Ensuring required lib folders exist..."
mkdir -p src/lib

echo "🧠 Recreating src/lib/i18n.ts"
cat > src/lib/i18n.ts <<'EOF'
export async function getDictionary(locale: string) {
  try {
    return (await import(`@/data/locales/${locale}.json`)).default
  } catch {
    return {}
  }
}
EOF

echo "🧠 Recreating src/lib/locale.ts"
cat > src/lib/locale.ts <<'EOF'
import { headers } from 'next/headers'

export function getLocale() {
  const headersList = headers()
  const pathname = headersList.get('x-invoke-path') || '/'
  const match = pathname.match(/^\/(en|es|fr|it)\b/)
  return match?.[1] || 'en'
}
EOF

echo "🧠 Patching src/lib/calculator-registry.ts"
cat > src/lib/calculator-registry.ts <<'EOF'
import fs from 'fs'
import path from 'path'

const dir = path.join(process.cwd(), 'generated/calculators')

export async function loadCalculator(slug: string) {
  return await import(`../../generated/calculators/${slug}.js`)
}

export function getAllSlugs(): string[] {
  return fs.existsSync(dir)
    ? fs.readdirSync(dir).map(f => f.replace('.js', ''))
    : []
}

export function getCalculatorsByCategory(_cat: string): { slug: string, title: string }[] {
  // TEMP MOCK (replace with category tree lookup if available)
  return getAllSlugs().map(slug => ({
    slug,
    title: slug.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase())
  }))
}
EOF

echo "🧼 Cleaning stale .js cache files..."
rm -rf .next/cache

echo "✅ All critical lib files restored. You can now restart with:"
echo "   npm run dev"
