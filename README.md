# file-butler 🗂️

**Automatically organize your Mac files by type and project name with consistent YYYY-MM-DD dating. Uses F2, RnR, and Organize for intelligent batch renaming, regex patterns, and rule-based automation.**

---

## Features

✅ **Auto-organize** files into `FileType/ProjectName/` structures
✅ **Batch rename** with YYYY-MM-DD date prefixes  
✅ **Regex-powered renaming** via RnR for complex patterns
✅ **Rule-based automation** with Organize tool
✅ **Scans all directories** (Desktop, Documents, Downloads, Projects, etc.)
✅ **Safe by default** — dry-run mode previews changes
✅ **Undo functionality** for mistake recovery

---

## Installation

### Quick Start

```bash
chmod +x install.sh file-butler.sh
./install.sh
```

This installs F2, RnR, and Organize automatically.

---

## Configuration

### 1. File Types (`config/file-types.conf`)
```
Documents=pdf,doc,docx,txt,xlsx,csv
Images=jpg,jpeg,png,gif,svg,webp
Videos=mp4,mov,avi,mkv,flv
Audio=mp3,wav,aac,flac,m4a
Code=js,py,ts,java,go,rs,cpp
Archives=zip,tar,gz,rar,7z
```

### 2. Projects (`config/projects.conf`)
```
website=~/Projects/website
mobile=~/Projects/mobile
backend=~/Projects/backend
```

### 3. Organization Rules (`config/organize-rules.yaml`)
Define custom automation rules for file organization.

---

## Usage

**Dry-run (preview changes):**
```bash
./file-butler.sh --dry-run
```

**Execute:**
```bash
./file-butler.sh --execute
```

**Undo:**
```bash
./file-butler.sh --undo
```

---

## Tools Used

- **F2** — Fast batch renaming with undo
- **RnR** — Regex-based advanced renaming  
- **Organize** — Rule-based automation

---

## License

MIT License
