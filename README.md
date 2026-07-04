# file-butler 🗂️

> Automatically organize your Mac files by type and project name with YYYY-MM-DD dating.

## One-Command Install

```bash
curl -fsSL https://raw.githubusercontent.com/weedappcreator/FILE-BUTLER-/main/install.sh | bash
```

Then open a new terminal and run:

```bash
file-butler
```

---

## Usage

### Interactive mode (recommended)
```bash
file-butler
```
Launches a guided menu — choose folder, mode, and preview before applying.

### Direct commands
```bash
file-butler --path ~/Downloads --dry-run    # Preview changes
file-butler --path ~/Downloads --execute    # Apply changes
file-butler --install                       # Install/update dependencies
file-butler --log                           # View activity log
file-butler --help                          # Show help
```

---

## What it does

1. **Renames** all files with `YYYY-MM-DD_` prefix
2. **Organizes** files into type folders:
   - `Documents/` — PDF, Word, Excel, etc.
   - `Images/` — JPG, PNG, HEIC, etc.
   - `Videos/` — MP4, MOV, etc.
   - `Audio/` — MP3, WAV, etc.
   - `Code/` — JS, Python, JSON, etc.
   - `Archives/` — ZIP, RAR, etc.
   - `Design/` — Figma, Sketch, etc.
   - `Installers/` — DMG, PKG, etc.
3. **Moves** existing project folders into `Projects/`
4. **Unknown files** are left in place (never lost)

---

## Powered by

- **F2** — Fast batch file renaming
- **RnR** — Regex-based advanced renaming
- Pure bash organization (no Python/Homebrew required)

---

## Requirements

- macOS
- `curl` (pre-installed on Mac)
- Internet connection (for first install only)

---

## License

MIT License
