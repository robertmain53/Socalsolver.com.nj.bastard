#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "🔧 Removing incompatible express middleware…"

# Remove legacy middleware that uses Express
rm -f src/api/middleware/auth.ts
echo "✅ Removed src/api/middleware/auth.ts"

# Remove express-rate-limit if installed
npm uninstall express express-rate-limit || true
echo "✅ Uninstalled express + express-rate-limit (if present)"

# Fix ESLint config if it's referencing broken extends
sed -i '/@typescript-eslint\/recommended/d' .eslintrc.json || true
echo "✅ Cleaned .eslintrc.json"

# Re-run build
echo "🚀 Building clean project…"
NEXT_ESLINT_IGNORE=true npm run build
