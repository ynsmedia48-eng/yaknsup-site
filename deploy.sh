#!/bin/bash
# Yak N Sup — deploy script
# Usage: bash deploy.sh "what you changed"

NETLIFY_TOKEN="nfp_t2R7bMoERiyezJKqkHywVG8NBHjkBjVBbf44"
SITE_ID="458ff35f-3d9a-4244-8278-30adbbcfc4c6"
DIR="$(cd "$(dirname "$0")" && pwd)"
MSG="${1:-update}"

echo "📦 Committing & pushing to GitHub..."
cd "$DIR"
git add -A
git commit -m "$MSG" 2>/dev/null || echo "(nothing new to commit)"
git push origin main

echo "🚀 Deploying to Netlify..."
cd "$DIR"
zip -r /tmp/yaknsup-deploy.zip . \
  --exclude "*.git*" \
  --exclude "deploy.sh" \
  --exclude ".netlify*" \
  --exclude "*.DS_Store" \
  -q

DEPLOY=$(curl -s -X POST \
  -H "Authorization: Bearer $NETLIFY_TOKEN" \
  -H "Content-Type: application/zip" \
  --data-binary @/tmp/yaknsup-deploy.zip \
  "https://api.netlify.com/api/v1/sites/$SITE_ID/deploys")

STATE=$(echo "$DEPLOY" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('state','unknown'))")
URL=$(echo "$DEPLOY" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('deploy_url',''))")

echo "✅ Deploy state: $STATE"
echo "🌐 Live at: https://yaknsup.netlify.app"
rm /tmp/yaknsup-deploy.zip
