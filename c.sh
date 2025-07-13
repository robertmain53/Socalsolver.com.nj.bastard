#!/bin/bash
set -euo pipefail

echo "🔁 Scaffolding core API route.ts handlers if missing..."

# Base API routes with optional stub contents
declare -A ROUTES
ROUTES["improve"]=$'export async function POST(req: Request) {\n  return new Response("Improve endpoint");\n}'
ROUTES["review"]=$'export async function POST(req: Request) {\n  return new Response("Review endpoint");\n}'
ROUTES["admin/list-logs"]=$'export const runtime="edge";\nexport async function GET() {\n  return new Response("[]");\n}'
ROUTES["health"]=$'export async function GET() {\n  return new Response("OK");\n}'
ROUTES["metrics"]=$'export async function GET() {\n  return new Response("{}");\n}'

for route in "${!ROUTES[@]}"; do
  route_path="src/app/api/$route/route.ts"
  mkdir -p "$(dirname "$route_path")"
  if [[ ! -f "$route_path" ]]; then
    echo -e "${ROUTES[$route]}" > "$route_path"
    echo "✅ Created stub for: $route_path"
  else
    echo "🟡 Exists: $route_path"
  fi
done

echo "🌍 Linking locale-aware API routes..."

LOCALES=(en es fr it)
for locale in "${LOCALES[@]}"; do
  for route in "${!ROUTES[@]}"; do
    source_rel="../../../../api/$route/route.ts"
    target_dir="src/app/$locale/api/$(dirname "$route")"
    mkdir -p "$target_dir"
    link_path="$target_dir/route.ts"

    [ -L "$link_path" ] || [ -f "$link_path" ] && rm -f "$link_path"
    ln -s "$source_rel" "$link_path"
    echo "🔗 Linked: $link_path → $source_rel"
  done
done

echo "🧱 Verifying localized pages..."

for locale in "${LOCALES[@]}"; do
  # Home page
  if [[ ! -f "src/app/$locale/page.tsx" ]]; then
    cat > "src/app/$locale/page.tsx" <<EOF
import { getDictionary } from '@/lib/i18n'
import Link from 'next/link'
import { getLocale } from '@/lib/locale'

export default async function Home() {
  const locale = getLocale()
  const t = await getDictionary(locale)
  return (
    <main className="p-8">
      <h1>{t?.home?.title || 'Welcome'}</h1>
      <p>{t?.home?.description || 'Localized calculators at your service.'}</p>
      <ul>
        {Object.keys(t?.categories || {}).map(cat => (
          <li key={cat}>
            <Link href={\`/\${locale}/\${cat}\`}>{t.categories[cat]?.title || cat}</Link>
          </li>
        ))}
      </ul>
    </main>
  )
}
EOF
    echo "🏠 Scaffolding home: /$locale/page.tsx"
  fi

  # Subcategory
  mkdir -p "src/app/$locale/[cat]/[subcat]"
  if [[ ! -f "src/app/$locale/[cat]/[subcat]/page.tsx" ]]; then
    cat > "src/app/$locale/[cat]/[subcat]/page.tsx" <<EOF
export default function SubCategoryPage() {
  return <div>Subcategory page placeholder</div>;
}
EOF
    echo "📁 Created: /$locale/[cat]/[subcat]/page.tsx"
  fi

  # Subsubcat
  mkdir -p "src/app/$locale/[cat]/[subcat]/[subsubcat]"
  if [[ ! -f "src/app/$locale/[cat]/[subcat]/[subsubcat]/page.tsx" ]]; then
    cat > "src/app/$locale/[cat]/[subcat]/[subsubcat]/page.tsx" <<EOF
export default function SubSubCategoryPage() {
  return <div>Sub-subcategory page placeholder</div>;
}
EOF
    echo "📁 Created: /$locale/[cat]/[subcat]/[subsubcat]/page.tsx"
  fi
done

echo "✅ All locale routes and pages are now scaffolded."
