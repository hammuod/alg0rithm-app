#!/usr/bin/env bash
# Alg0rithm App – Smart multi-distro Linux installer
# Detects distro → uses correct package manager → elevates only when needed
# Covers: Debian family, RPM family, Arch, openSUSE, Alpine, Void, and any other
# 100% free

set -euo pipefail

APP_NAME="alg0rithm"
APP_DISPLAY="Alg0rithm"
VERSION="3.0.0"
REPO="https://github.com/hammuod/alg0rithm-app"
RELEASES="${REPO}/releases/latest/download"
WEB="https://alg0rithm.dev"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

run_priv() {
  if [[ $EUID -eq 0 ]]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    info "صلاحيات مطلوبة / privileges needed..."
    sudo "$@"
  elif command -v doas >/dev/null 2>&1; then
    doas "$@"
  else
    error "Need root (sudo or doas)."
    exit 1
  fi
}

detect() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    ID="${ID:-unknown}"
    ID_LIKE="${ID_LIKE:-}"
    NAME="${NAME:-Unknown}"
    VERSION_ID="${VERSION_ID:-}"
  else
    ID="unknown"; ID_LIKE=""; NAME="Unknown"; VERSION_ID=""
  fi

  case "$ID" in
    # Debian family (incl. Zorin, MX, Deepin, ...)
    ubuntu|debian|linuxmint|pop|elementary|zorin|kali|raspbian|neon|mx|deepin|pureos|tails|parrot|devuan)
      FAMILY=debian; PM=apt ;;
    # RPM / RHEL family
    fedora|rhel|centos|rocky|almalinux|ol|amazon|nobara|mageia|openmandriva)
      FAMILY=rhel
      if command -v dnf >/dev/null 2>&1; then PM=dnf
      elif command -v yum >/dev/null 2>&1; then PM=yum
      else PM=dnf; fi
      ;;
    # Arch family
    arch|manjaro|endeavouros|garuda|artix|cachyos|archcraft|arcolinux)
      FAMILY=arch; PM=pacman ;;
    # SUSE family
    opensuse*|sles|suse)
      FAMILY=suse; PM=zypper ;;
    # Alpine
    alpine)
      FAMILY=alpine; PM=apk ;;
    # Void
    void)
      FAMILY=void; PM=xbps ;;
    *)
      if [[ "$ID_LIKE" == *debian* || "$ID_LIKE" == *ubuntu* ]]; then
        FAMILY=debian; PM=apt
      elif [[ "$ID_LIKE" == *rhel* || "$ID_LIKE" == *fedora* || "$ID_LIKE" == *centos* ]]; then
        FAMILY=rhel; PM=dnf
      elif [[ "$ID_LIKE" == *arch* ]]; then
        FAMILY=arch; PM=pacman
      elif [[ "$ID_LIKE" == *suse* ]]; then
        FAMILY=suse; PM=zypper
      else
        FAMILY=unknown; PM=unknown
      fi
      ;;
  esac
}

# Prefer downloading a real package from Releases if available
try_release_package() {
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  case "$FAMILY" in
    debian)
      local deb="${APP_NAME}_${VERSION}_all.deb"
      info "Trying .deb from releases..."
      if curl -fsSL "$RELEASES/$deb" -o "$tmp/$deb" 2>/dev/null; then
        run_priv dpkg -i "$tmp/$deb" || run_priv apt-get install -f -y
        success "Installed via .deb"
        return 0
      fi
      ;;
    rhel|suse)
      info "Trying .rpm from releases..."
      # Filename may vary with dist tag; try common patterns
      for pattern in \
        "${APP_NAME}-${VERSION}-1.*.noarch.rpm" \
        "${APP_NAME}-${VERSION}-1.noarch.rpm"; do
        # We cannot glob remote; try fixed names produced by CI
        true
      done
      # Fallback: list is hard without API; try a known name
      if curl -fsSL "$RELEASES/${APP_NAME}-${VERSION}-1.noarch.rpm" \
           -o "$tmp/${APP_NAME}.rpm" 2>/dev/null; then
        if [[ "$FAMILY" == "suse" ]]; then
          run_priv zypper install -y "$tmp/${APP_NAME}.rpm" || run_priv rpm -Uvh "$tmp/${APP_NAME}.rpm"
        else
          run_priv $PM install -y "$tmp/${APP_NAME}.rpm" || run_priv rpm -Uvh "$tmp/${APP_NAME}.rpm"
        fi
        success "Installed via .rpm"
        return 0
      fi
      ;;
  esac
  return 1
}

install_launcher() {
  local BASE="${XDG_DATA_HOME:-$HOME/.local/share}"
  local BIN="${XDG_BIN_HOME:-$HOME/.local/bin}"
  local DESKTOP_DIR="$BASE/applications"
  local ICON_DIR="$BASE/icons/hicolor/256x256/apps"

  mkdir -p "$BIN" "$DESKTOP_DIR" "$ICON_DIR"

  cat > "$BIN/$APP_NAME" << EOF
#!/usr/bin/env bash
URL="$WEB"
if command -v xdg-open >/dev/null 2>&1; then
  exec xdg-open "\$URL"
elif command -v gio >/dev/null 2>&1; then
  exec gio open "\$URL"
else
  echo "Open: \$URL"
fi
EOF
  chmod +x "$BIN/$APP_NAME"

  cat > "$DESKTOP_DIR/${APP_NAME}.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${APP_DISPLAY}
GenericName=Algorithm Learning
Comment=Learn algorithms – simple, fast, offline-ready
Comment[ar]=تعلم الخوارزميات – بسيط وسريع ويدعم العمل بدون إنترنت
Exec=${BIN}/${APP_NAME}
Icon=${APP_NAME}
Terminal=false
Categories=Education;Development;
StartupNotify=true
Keywords=algorithm;learn;code;programming;
EOF

  curl -fsSL "https://raw.githubusercontent.com/hammuod/Alg0rithm/main/imgs/icon.png" \
    -o "$ICON_DIR/${APP_NAME}.png" 2>/dev/null && success "Icon installed" || true

  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
  fi

  if [[ ":$PATH:" != *":$BIN:"* ]]; then
    warn "Add to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
  fi

  success "Launcher ready → run: $APP_NAME"
  info  "Works on: Debian, Ubuntu, Zorin, Mint, Fedora, Arch, openSUSE, Alpine, Void, ..."
}

try_flatpak() {
  command -v flatpak >/dev/null 2>&1 || return 1
  info "Flatpak available (preferred when package is published)"
  return 1
}

main() {
  echo -e "${CYAN}"
  cat << 'BANNER'
  ╔══════════════════════════════════════════╗
  ║       Alg0rithm App – Linux Installer    ║
  ║  All distros • Free • Light • Clean      ║
  ╚══════════════════════════════════════════╝
BANNER
  echo -e "${NC}"

  detect
  info "System : $NAME $VERSION_ID ($ID)"
  info "Family : $FAMILY  |  Manager : $PM"

  if try_flatpak; then
    success "Installed via Flatpak"
  elif try_release_package; then
    :
  else
    info "No release package yet – installing universal launcher"
    install_launcher
  fi

  echo
  success "Done."
  echo "  Web     : $WEB"
  echo "  Source  : https://github.com/hammuod/Alg0rithm"
  echo "  App repo: $REPO"
  echo
}

main "$@"
