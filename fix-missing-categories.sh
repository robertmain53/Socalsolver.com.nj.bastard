#!/bin/bash
set -euo pipefail

cat > src/data/locales/en.json <<'EOF'
{
  "home": {
    "title": "Welcome to SoCalSolver",
    "description": "Smart calculators for every need."
  },
  "categories": {
    "finance": { "title": "Finance" },
    "health": { "title": "Health" },
    "math": { "title": "Mathematics" }
  }
}
EOF

echo "🌐 Updating placeholders for es/fr/it"
for lang in es fr it; do
  cp src/data/locales/en.json src/data/locales/$lang.json
done

echo "✅ Category titles injected"
