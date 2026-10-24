# Alg0rithm App

> Native application packaging for [Alg0rithm](https://github.com/hammuod/Alg0rithm)  
> **Free plan only** — everything builds on GitHub Actions free tier.

**Order of work:** Linux → Windows → macOS → Android

---

## العربية

تطبيق Alg0rithm الأصلي.

- المشروع الأساسي (`Alg0rithm`) يبقى موقع ويب + PWA فقط.
- هذا الريبو مخصص للتطبيقات والحزم.
- نبدأ بلينكس (كل التوزيعات + Flatpak + AppImage + deb).
- كل شيء مجاني ويعمل على GitHub Actions بدون أي تكلفة.

### تثبيت سريع (لينكس)

```bash
curl -fsSL https://raw.githubusercontent.com/hammuod/alg0rithm-app/main/install.sh | bash
```

---

## English

Native Alg0rithm application packages.

- Core project stays pure web/PWA.
- This repo = native apps & packages.
- **Linux first** (all distros + Flatpak + AppImage + deb).
- 100% free — builds on GitHub free runners only.

### Quick install (Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/hammuod/alg0rithm-app/main/install.sh | bash
```

---

## Français

Paquets natifs pour Alg0rithm.

- Le projet principal reste un site + PWA.
- Ce dépôt = applications natives et paquets.
- **Linux d'abord** (toutes distributions + Flatpak + AppImage + deb).
- Entièrement gratuit (GitHub Actions gratuit).

### Installation rapide (Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/hammuod/alg0rithm-app/main/install.sh | bash
```

---

## Roadmap (free tier)

| Stage | Platform | Formats | Status |
|-------|----------|---------|--------|
| 1 | **Linux** | install.sh, .deb, AppImage, Flatpak | In progress |
| 2 | Windows | portable + installer | Next |
| 3 | macOS | .dmg / .app | Later |
| 4 | Android | APK / TWA | Later |

---

## Linux support matrix

| Distro family | Package manager | Supported |
|---------------|-----------------|-----------|
| Debian / Ubuntu / Mint / Pop | apt + .deb | Yes |
| Fedora / RHEL / Rocky / Alma | dnf / yum + .rpm | Yes |
| Arch / Manjaro / Endeavour | pacman | Yes |
| openSUSE | zypper | Yes |
| Alpine | apk | Yes |
| Any | **Flatpak** | Yes (preferred) |
| Any | **AppImage** | Yes (portable) |

---

## Project layout

```
alg0rithm-app/
├── install.sh                 # Smart multi-distro installer
├── packaging/
│   ├── deb/                   # Debian package files
│   ├── appimage/              # AppImage recipe
│   └── flatpak/               # Flatpak manifest
├── scripts/
│   └── build-linux.sh         # Local / CI build helper
├── web/                       # Cached copy of the PWA (optional)
└── .github/workflows/
    └── build-linux.yml        # Free Ubuntu runners only
```

---

## License

AGPL-3.0 — same as the main project.  
Creator: **Hammoud (hammuod)**
