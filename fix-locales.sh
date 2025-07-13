#!/bin/bash
set -euo pipefail

mkdir -p src/data/locales

echo "📦 Creating en.json with basic home section"
cat > src/data/locales/en.json <<'EOF'
{
  "home": {
    "title": "Welcome to SoCalSolver",
    "description": "Smart calculators for every need."
  }
}
EOF

echo "🌐 Copying placeholders for es/fr/it"
for lang in es fr it; do
  cp src/data/locales/en.json src/data/locales/$lang.json
done

echo "✅ Locale files are in place."
