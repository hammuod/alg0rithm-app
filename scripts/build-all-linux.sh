#!/usr/bin/env bash
# Build ALL Linux packages (free tier friendly)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p dist

echo "=== 1/5 DEB (Debian/Ubuntu/Mint/Pop/Zorin/Elementary/...) ==="
chmod +x scripts/build-deb.sh && ./scripts/build-deb.sh

echo "=== 2/5 RPM (Fedora/RHEL/Rocky/Alma/openSUSE) ==="
chmod +x scripts/build-rpm.sh && ./scripts/build-rpm.sh

echo "=== 3/5 Arch (Arch/Manjaro/Endeavour/Garuda) ==="
chmod +x scripts/build-arch.sh && ./scripts/build-arch.sh

echo "=== 4/5 Alpine ==="
chmod +x scripts/build-alpine.sh && ./scripts/build-alpine.sh

echo "=== 5/5 Universal tarball (any distro) ==="
chmod +x scripts/build-tarball.sh && ./scripts/build-tarball.sh

echo
echo "All Linux packages:"
ls -lh dist/ || true
