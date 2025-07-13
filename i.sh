#!/bin/bash
set -euo pipefail

echo "🧹 Removing legacy Express files..."
rm -f src/api/router.ts
rm -f src/api/middleware/auth.ts
rm -f src/api/monitoring/metrics.ts

echo "📦 Removing unused Express-related packages..."
npm remove express cors body-parser express-rate-limit || true
yarn remove express cors body-parser express-rate-limit || true

echo "🛠️  Patching package.json scripts..."
npx json -I -f package.json -e \
  'this.scripts={"dev":"next dev","build":"next build","start":"next start"}'

echo "🔧 Updating tsconfig.json to remove deprecated path mappings..."
npx json -I -f tsconfig.json -e \
  'if (this.compilerOptions.paths) delete this.compilerOptions.paths["@/api/*"]'

echo "🧪 Verifying valid Next.js API route files..."
for path in \
  src/app/api/improve/route.ts \
  src/app/api/review/route.ts \
  src/app/api/admin/list-logs/route.ts \
  src/app/api/health/route.ts \
  src/app/api/metrics/route.ts; do
  if [ ! -f "$path" ]; then
    echo "❌ Missing required route: $path"
    exit 1
  fi
done

echo "🧼 Cleaning .next cache..."
rm -rf .next

echo "✅ Express removed and Next.js API routes cleaned up."
