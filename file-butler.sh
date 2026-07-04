#!/bin/bash

# Add ~/bin to PATH for tools installed without Homebrew
export PATH="$HOME/bin:$HOME/Library/Python/3.9/bin:$HOME/Library/Python/3.11/bin:$PATH"

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/file-butler.log"
DRY_RUN=true

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log()    { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }
ok()     { echo -e "${GREEN}✅ $1${NC}"; }
err()    { echo -e "${RED}❌ $1${NC}"; }
warn()   { echo -e "${YELLOW}⚠️  $1${NC}"; }
info()   { echo -e "${CYAN}ℹ️  $1${NC}"; }
dry_e()  { echo -e "  ${YELLOW}[DRY-RUN]${NC} $1"; }
header() { echo -e "\n${BLUE}══════════════════════════════════════\n  $1\n══════════════════════════════════════${NC}"; }

# ─────────────────────────────────
# File type detection (no assoc arrays)
# ─────────────────────────────────

get_file_type() {
    local ext
    ext=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
    case "$ext" in
        pdf|doc|docx|txt|xlsx|csv|pptx|pages|numbers|keynote|odt|rtf|md)
            echo "Documents" ;;
        jpg|jpeg|png|gif|svg|webp|bmp|ico|heic|tiff|raw|eps|psd|ai)
            echo "Images" ;;
        mp4|mov|avi|mkv|flv|wmv|webm|m4v|mpg|mpeg|3gp)
            echo "Videos" ;;
        mp3|wav|aac|flac|m4a|wma|ogg|opus|alac|aiff)
            echo "Audio" ;;
        js|ts|jsx|tsx|py|java|go|rs|cpp|c|h|swift|kt|rb|php|css|html|json|xml|yaml|yml|sh|bash|pl|lua|r|scala|dart)
            echo "Code" ;;
        zip|tar|gz|rar|7z|bz2|xz|iso|bz)
            echo "Archives" ;;
        dmg|pkg|exe|app|bin|jar)
            echo "Installers" ;;
        fig|figma|sketch|xd|indd)
            echo "Design" ;;
        *)
            echo "Other" ;;
    esac
}

# ─────────────────────────────────
# Dependency check
# ─────────────────────────────────

check_deps() {
    header "Checking Dependencies"
    local missing=0
    if command -v f2 &>/dev/null; then
        ok "F2 found"
    else
        err "F2 not found — run ./install.sh"; missing=1
    fi
    if command -v rnr &>/dev/null; then
        ok "RnR found"
    else
        err "RnR not found — run ./install.sh"; missing=1
    fi
    if command -v organize &>/dev/null; then
        ok "Organize found"
    else
        warn "Organize not found — using built-in organizer (optional)"
    fi
    [ $missing -eq 1 ] && exit 1
}

# ─────────────────────────────────
# Rename files with YYYY-MM-DD prefix using F2
# ─────────────────────────────────

rename_with_dates() {
    local dir="$1"
    header "Step 1/2 — Date Rename (F2)"
    info "Adding YYYY-MM-DD prefix to files..."

    local count=0
    while IFS= read -r file; do
        local base fdate new_name parent
        base=$(basename "$file")
        parent=$(dirname "$file")

        # Skip hidden, already prefixed, or dirs
        [[ "$base" == .* ]] && continue
        [[ "$base" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}_ ]] && continue

        fdate=$(stat -f %Sm -t "%Y-%m-%d" "$file" 2>/dev/null || date +%Y-%m-%d)
        new_name="${fdate}_${base}"

        if [ "$DRY_RUN" = true ]; then
            dry_e "$base  →  $new_name"
        else
            mv "$file" "$parent/$new_name" && log "Renamed: $base → $new_name"
        fi
        count=$((count + 1))
    done < <(find "$dir" -maxdepth 1 -type f ! -name ".*" 2>/dev/null)

    [ $count -eq 0 ] && info "No files needed renaming in $dir" || ok "$count file(s) processed"
}

# ─────────────────────────────────
# Organize files into type folders
# ─────────────────────────────────

organize_by_type() {
    local dir="$1"
    header "Step 2/2 — Organize by Type"
    info "Moving files into type-based folders..."

    local moved=0
    while IFS= read -r file; do
        local base ext type target
        base=$(basename "$file")
        [[ "$base" == .* ]] && continue

        ext="${base##*.}"
        [ "$ext" = "$base" ] && ext="other"
        type=$(get_file_type "$ext")
        target="$dir/$type"

        [ "$(dirname "$file")" = "$target" ] && continue

        if [ "$DRY_RUN" = true ]; then
            dry_e "$base  →  $type/$base"
        else
            mkdir -p "$target"
            mv "$file" "$target/$base" && log "Organized: $base → $type/"
        fi
        moved=$((moved + 1))
    done < <(find "$dir" -maxdepth 1 -type f ! -name ".*" 2>/dev/null)

    [ $moved -eq 0 ] && info "Nothing to organize in $dir" || ok "$moved file(s) organized"
}

# ─────────────────────────────────
# Apply Organize rules (optional)
# ─────────────────────────────────

apply_rules() {
    local rules="$SCRIPT_DIR/config/organize-rules.yaml"
    ! command -v organize &>/dev/null && return
    ! [ -f "$rules" ] && return

    header "Applying Custom Rules (Organize)"
    if [ "$DRY_RUN" = true ]; then
        organize --config "$rules" --simulate
    else
        organize --config "$rules"
    fi
}

# ─────────────────────────────────
# Folders to scan
# ─────────────────────────────────

scan_folders() {
    echo "$HOME/Downloads"
    echo "$HOME/Desktop"
    echo "$HOME/Documents"
    [ -d "$HOME/Projects" ] && echo "$HOME/Projects"
    [ -d "$HOME/Dev" ]      && echo "$HOME/Dev"
    [ -d "$HOME/Work" ]     && echo "$HOME/Work"
}

# ─────────────────────────────────
# Help
# ─────────────────────────────────

show_help() {
    echo ""
    echo -e "${BLUE}file-butler v${VERSION}${NC} — Mac File Organization Tool"
    echo ""
    echo -e "${CYAN}USAGE:${NC}   ./file-butler.sh [OPTIONS]"
    echo ""
    echo -e "${CYAN}OPTIONS:${NC}"
    echo "  --dry-run           Preview changes (default — safe)"
    echo "  --execute           Apply changes"
    echo "  --path <dir>        Target a specific directory"
    echo "  --rename-only       Only add date prefix"
    echo "  --organize-only     Only move files into type folders"
    echo "  --log               Show activity log"
    echo "  --help              Show this help"
    echo "  --version           Show version"
    echo ""
    echo -e "${CYAN}EXAMPLES:${NC}"
    echo "  ./file-butler.sh --dry-run"
    echo "  ./file-butler.sh --path ~/Downloads --dry-run"
    echo "  ./file-butler.sh --execute"
    echo ""
}

# ─────────────────────────────────
# Main
# ─────────────────────────────────

main() {
    local custom_path=""
    local rename_only=false
    local organize_only=false

    while [ $# -gt 0 ]; do
        case "$1" in
            --help)         show_help; exit 0 ;;
            --version)      echo "file-butler v$VERSION"; exit 0 ;;
            --dry-run)      DRY_RUN=true;  shift ;;
            --execute)      DRY_RUN=false; shift ;;
            --path)         custom_path="$2"; shift 2 ;;
            --rename-only)  rename_only=true;  shift ;;
            --organize-only) organize_only=true; shift ;;
            --log)          [ -f "$LOG_FILE" ] && tail -50 "$LOG_FILE"; exit 0 ;;
            *) err "Unknown option: $1"; show_help; exit 1 ;;
        esac
    done

    header "file-butler v$VERSION"
    check_deps

    [ "$DRY_RUN" = true ] && warn "DRY-RUN MODE — no files will be moved"

    if [ -n "$custom_path" ]; then
        [ ! -d "$custom_path" ] && { err "Directory not found: $custom_path"; exit 1; }
        info "Target: $custom_path"
        [ "$organize_only" = false ] && rename_with_dates "$custom_path"
        [ "$rename_only"   = false ] && organize_by_type  "$custom_path"
    else
        while IFS= read -r folder; do
            [ ! -d "$folder" ] && continue
            info "Scanning: $folder"
            [ "$organize_only" = false ] && rename_with_dates "$folder"
            [ "$rename_only"   = false ] && organize_by_type  "$folder"
        done < <(scan_folders)
    fi

    apply_rules

    if [ "$DRY_RUN" = true ]; then
        echo ""
        ok "Preview complete! To apply changes run:"
        echo -e "   ${GREEN}./file-butler.sh --execute${NC}"
    else
        header "Complete!"
        ok "All done. See file-butler.log for details."
        log "=== Run completed ==="
    fi
}

main "$@"
