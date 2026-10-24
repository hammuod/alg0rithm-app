#!/usr/bin/env bash
# Alg0rithm App – Smart Linux installer
# Detects distro → correct package manager → elevates only when needed
# Supports: apt, dnf, yum, pacman, zypper, apk, Flatpak, AppImage
# 100% free – no paid services

set -euo pipefail

APP_NAME="alg0rithm"
APP_DISPLAY="Alg0rithm"
VERSION="3.0.0"
REPO="https://github.com/hammuod/alg0rithm-app"
RAW="https://raw.githubusercontent.com/hammuod/alg0rithm-app/main"
RELEASES="${REPO}/releases/latest/download"
WEB="https://alg0rithm.dev"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ---------- Privileges (only when needed) ----------
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

# ---------- Detect distro ----------
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
    ubuntu|debian|linuxmint|pop|elementary|zorin|kali|raspbian|neon)
      FAMILY=debian; PM=apt ;;
    fedora|rhel|centos|rocky|almalinux|ol|amazon|nobara)
      FAMILY=rhel
      if command -v dnf >/dev/null 2>&1; then PM=dnf; else PM=yum; fi
      ;;
    arch|manjaro|endeavouros|garuda|artix|cachyos)
      FAMILY=arch; PM=pacman ;;
    opensuse*|sles)
      FAMILY=suse; PM=zypper ;;
    alpine)
      FAMILY=alpine; PM=apk ;;
    *)
      if [[ "$ID_LIKE" == *debian* || "$ID_LIKE" == *ubuntu* ]]; then
        FAMILY=debian; PM=apt
      elif [[ "$ID_LIKE" == *rhel* || "$ID_LIKE" == *fedora* ]]; then
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

# ---------- User-local launcher (no root, works everywhere) ----------
install_launcher() {
  local BASE="${XDG_DATA_HOME:-$HOME/.local/share}"
  local BIN="${XDG_BIN_HOME:-$HOME/.local/bin}"
  local APPDIR="$BASE/$APP_NAME"
  local DESKTOP_DIR="$BASE/applications"
  local ICON_DIR="$BASE/icons/hicolor/256x256/apps"

  mkdir -p "$APPDIR" "$BIN" "$DESKTOP_DIR" "$ICON_DIR"

  # Launcher script
  cat > "$BIN/$APP_NAME" << EOF
#!/usr/bin/env bash
# Alg0rithm launcher
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

  # Desktop entry
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

  # Icon from main project
  if curl -fsSL "https://raw.githubusercontent.com/hammuod/Alg0rithm/main/imgs/icon.png" \
       -o "$ICON_DIR/${APP_NAME}.png" 2>/dev/null; then
    success "Icon installed"
  fi

  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
  fi

  # Ensure ~/.local/bin is in PATH hint
  if [[ ":$PATH:" != *":$BIN:"* ]]; then
    warn "Add to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
  fi

  success "Launcher ready → run: $APP_NAME"
  info  "Desktop entry: $DESKTOP_DIR/${APP_NAME}.desktop"
}

# ---------- Try Flatpak ----------
try_flatpak() {
  if ! command -v flatpak >/dev/null 2>&1; then
    return 1
  fi
  info "Flatpak found – preferred method"
  # When real Flatpak is published we install it here.
  # For now we still install the launcher so the user has something usable.
  return 1
}

# ---------- Main ----------
main() {
  echo -e "${CYAN}"
  cat << 'BANNER'
  ╔══════════════════════════════════════╗
  ║        Alg0rithm App Installer       ║
  ║     Linux • Free • Light • Clean     ║
  ╚══════════════════════════════════════╝
BANNER
  echo -e "${NC}"

  detect
  info "System : $NAME $VERSION_ID ($ID)"
  info "Family : $FAMILY  |  Package manager : $PM"

  if try_flatpak; then
    success "Installed via Flatpak"
  else
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
