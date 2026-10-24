# Alg0rithm App

> Native packaging for [Alg0rithm](https://github.com/hammuod/Alg0rithm)  
> **Free plan only** — GitHub Actions free runners.

**Order:** Linux (all distros) → Windows → macOS → Android

---

## العربية

حزم Alg0rithm لكل توزيعات لينكس.

### تثبيت سريع

```bash
curl -fsSL https://raw.githubusercontent.com/hammuod/alg0rithm-app/main/install.sh | bash
```

السكربت يكتشف توزيعتك تلقائياً (بما فيها Zorin و Mint و Fedora و Arch و openSUSE و Alpine و Void وغيرها).

---

## English

### Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/hammuod/alg0rithm-app/main/install.sh | bash
```

---

## Français

### Installation rapide

```bash
curl -fsSL https://raw.githubusercontent.com/hammuod/alg0rithm-app/main/install.sh | bash
```

---

## Linux packages built by CI

| Format | Distros |
|--------|---------|
| **`.deb`** | Debian, Ubuntu, Linux Mint, Pop!_OS, **Zorin OS**, Elementary, MX, Deepin, Kali, ... |
| **`.rpm`** | Fedora, RHEL, Rocky, Alma, CentOS, **openSUSE**, SLES |
| **Arch src** | Arch, Manjaro, EndeavourOS, Garuda, Artix, CachyOS |
| **Alpine src** | Alpine Linux |
| **Universal tarball** | Void, Gentoo, Slackware, NixOS (manual), any other |
| **Flatpak** | All (manifest ready) |
| **AppImage** | All (portable) |

---

## Build locally

```bash
./scripts/build-all-linux.sh
# outputs in dist/
```

Or individually:

```bash
./scripts/build-deb.sh
./scripts/build-rpm.sh
./scripts/build-arch.sh
./scripts/build-alpine.sh
./scripts/build-tarball.sh
```

---

## CI

Workflow: **Build ALL Linux packages**  
Runs on `ubuntu-latest` (free). Trigger manually from Actions or push a tag `v*`.

---

## License

AGPL-3.0 — same as main project.  
Creator: **Hammoud (hammuod)**
