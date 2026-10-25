# Alg0rithm App

Native packages for [Alg0rithm](https://github.com/hammuod/Alg0rithm).  
**Takes code from the main repo → packages it as an app.**

Trigger builds with tag: **`build*`** (example: `build`, `build-3.0.0`)

---

## Workflows (each file is independent)

| Workflow | File | Runner |
|----------|------|--------|
| DEB | `.github/workflows/deb.yml` | ubuntu |
| RPM | `.github/workflows/rpm.yml` | ubuntu |
| Arch | `.github/workflows/arch.yml` | ubuntu |
| Alpine | `.github/workflows/alpine.yml` | ubuntu |
| Tarball | `.github/workflows/tarball.yml` | ubuntu |
| AppImage | `.github/workflows/appimage.yml` | ubuntu |
| **Windows** | `.github/workflows/windows.yml` | windows-latest |
| **macOS** | `.github/workflows/macos.yml` | macos-latest |
| **Android** | `.github/workflows/android.yml` | ubuntu |

No job waits for another. Run any one alone from **Actions → Run workflow**.

---

## How it works

1. `scripts/fetch-web.sh` clones **hammuod/Alg0rithm** into `web/app`
2. Platform scripts embed that code into the package
3. Launcher opens the **local** app (offline), fallback to https://alg0rithm.dev

---

## Tag to build everything

```bash
git tag build
git push origin build
```

Or:

```bash
git tag build-3.0.0
git push origin build-3.0.0
```

Each workflow attaches its files to the same GitHub Release independently.

---

## Quick install (Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/hammuod/alg0rithm-app/main/install.sh | bash
```

---

## License

AGPL-3.0 — Hammoud (hammuod)
