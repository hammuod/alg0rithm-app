#!/usr/bin/env bash
# Android package: TWA / PWA bundle ready for Bubblewrap or manual APK later
# Free: ubuntu-latest — produces a structured Android web package + metadata

set -euo pipefail

VERSION="${VERSION:-3.0.0}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WEB_APP="$ROOT/web/app"
BUILD="$ROOT/build/android"
OUT="$ROOT/dist"

rm -rf "$BUILD"
mkdir -p "$BUILD/app" "$OUT"

if [[ ! -d "$WEB_APP" ]]; then
  chmod +x "$ROOT/scripts/fetch-web.sh"
  "$ROOT/scripts/fetch-web.sh"
fi

cp -a "$WEB_APP/." "$BUILD/app/"

# TWA / Bubblewrap style manifest helper
cat > "$BUILD/twa-manifest.json" << EOF
{
  "packageId": "dev.alg0rithm.app",
  "host": "alg0rithm.dev",
  "name": "Alg0rithm",
  "launcherName": "Alg0rithm",
  "display": "standalone",
  "themeColor": "#4A90E2",
  "navigationColor": "#4A90E2",
  "backgroundColor": "#ffffff",
  "startUrl": "/",
  "iconUrl": "https://alg0rithm.dev/imgs/icon.png",
  "maskableIconUrl": "https://alg0rithm.dev/imgs/icon.png",
  "appVersionName": "${VERSION}",
  "appVersionCode": 30000,
  "minSdkVersion": 21,
  "webManifestUrl": "https://alg0rithm.dev/manifest.json"
}
EOF

cat > "$BUILD/README-ANDROID.txt" << EOF
Alg0rithm Android package (${VERSION})

Contents:
  app/              Full web app from hammuod/Alg0rithm (offline assets)
  twa-manifest.json Ready for Google Bubblewrap (Trusted Web Activity)

To build a real APK (on your machine or CI with Android SDK):
  npm i -g @bubblewrap/cli
  bubblewrap init --manifest twa-manifest.json
  bubblewrap build

Or open https://alg0rithm.dev in Chrome and "Install app" (PWA).
EOF

cd "$BUILD"
tar -czf "$OUT/Alg0rithm-${VERSION}-android-web.tar.gz" app twa-manifest.json README-ANDROID.txt
sha256sum "$OUT/Alg0rithm-${VERSION}-android-web.tar.gz" \
  > "$OUT/Alg0rithm-${VERSION}-android-web.tar.gz.sha256"

echo "Android web package ready (TWA-ready)."
ls -lh "$OUT"/*android*
