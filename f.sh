#!/bin/bash
# Fix build error by ensuring admin log route uses Node.js runtime

TARGET_FILE="src/app/api/admin/list-logs/route.ts"

# Replace runtime line or insert it
if grep -q "export const runtime" "$TARGET_FILE"; then
  sed -i "s/export const runtime=.*/export const runtime='nodejs'/" "$TARGET_FILE"
else
  sed -i "2i export const runtime='nodejs'" "$TARGET_FILE"
fi

echo "✅ Fixed runtime in $TARGET_FILE"
