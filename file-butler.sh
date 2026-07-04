#!/bin/bash

set -e

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/file-butler.log"
BACKUP_DIR="$SCRIPT_DIR/.backups"
DRY_RUN=true
ORGANIZE_MODE=true

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

print_header() {
    echo -e "${BLUE}═══════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Load configuration
load_config() {
    if [[ ! -f "$SCRIPT_DIR/config/file-types.conf" ]]; then
        print_error "file-types.conf not found!"
        exit 1
    fi
    if [[ ! -f "$SCRIPT_DIR/config/projects.conf" ]]; then
        print_warning "projects.conf not found. Skipping project organization."
        ORGANIZE_MODE=false
    fi
}

# Check dependencies
check_dependencies() {
    print_header "Checking Dependencies"
    
    local missing=0
    
    if ! command -v f2 &> /dev/null; then
        print_error "F2 not installed. Run: ./install.sh"
        missing=1
    else
        print_success "F2 found"
    fi
    
    if ! command -v rnr &> /dev/null; then
        print_error "RnR not installed. Run: ./install.sh"
        missing=1
    else
        print_success "RnR found"
    fi
    
    if ! command -v organize &> /dev/null; then
        print_error "Organize not installed. Run: ./install.sh"
        missing=1
    else
        print_success "Organize found"
    fi
    
    if [[ $missing -eq 1 ]]; then
        exit 1
    fi
}

# Organize files by type
organize_by_type() {
    local target_dir="${1:-.}"
    
    print_header "Organizing Files by Type"
    
    # Read file-types.conf
    while IFS='=' read -r type extensions; do
        [[ "$type" =~ ^#.*$ ]] && continue
        [[ -z "$type" ]] && continue
        
        type=$(echo "$type" | xargs)
        extensions=$(echo "$extensions" | xargs)
        
        IFS=',' read -ra EXT_ARRAY <<< "$extensions"
        
        for ext in "${EXT_ARRAY[@]}"; do
            ext=$(echo "$ext" | xargs)
            find "$target_dir" -maxdepth 3 -type f -name "*.$ext" 2>/dev/null | while read -r file; do
                organize_file "$file" "$type"
            done
        done
    done < "$SCRIPT_DIR/config/file-types.conf"
}

# Organize single file
organize_file() {
    local file="$1"
    local type="$2"
    local basename=$(basename "$file")
    local dirname=$(dirname "$file")
    
    # Get file creation date
    local created_date=$(stat -f %Sm -t "%Y-%m-%d" "$file")
    
    # Target directory
    local target_dir="$dirname/$type"
    
    if [[ ! -d "$target_dir" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Would create: $target_dir"
        else
            mkdir -p "$target_dir"
            print_success "Created: $target_dir"
        fi
    fi
    
    # Rename with date prefix if not already done
    if [[ ! "$basename" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}_ ]]; then
        local new_name="${created_date}_${basename}"
    else
        local new_name="$basename"
    fi
    
    local target_file="$target_dir/$new_name"
    
    if [[ "$file" != "$target_file" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Would move: $basename → $type/$new_name"
            log "[DRY-RUN] Move: $file → $target_file"
        else
            mv "$file" "$target_file"
            print_success "Moved: $basename → $type/$new_name"
            log "Moved: $file → $target_file"
        fi
    fi
}

# Apply organization rules
apply_rules() {
    if [[ -f "$SCRIPT_DIR/config/organize-rules.yaml" ]]; then
        print_header "Applying Organization Rules"
        
        if [[ "$DRY_RUN" == true ]]; then
            organize --config "$SCRIPT_DIR/config/organize-rules.yaml" --simulate
        else
            organize --config "$SCRIPT_DIR/config/organize-rules.yaml"
        fi
    fi
}

# Show help
show_help() {
    cat << 'HELP'
file-butler - Mac File Organization Tool

USAGE:
    ./file-butler.sh [OPTIONS]

OPTIONS:
    --help              Show this help message
    --version           Show version
    --dry-run           Preview changes (default)
    --execute           Execute organization
    --path <dir>        Target directory (default: current)
    --undo              Undo last operation
    --log               Show activity log

EXAMPLES:
    ./file-butler.sh --dry-run
    ./file-butler.sh --path ~/Downloads --dry-run
    ./file-butler.sh --execute
    ./file-butler.sh --undo

HELP
}

# Main function
main() {
    local target_path="."
    
    print_header "file-butler v$VERSION"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --version)
                echo "file-butler version $VERSION"
                exit 0
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --execute)
                DRY_RUN=false
                shift
                ;;
            --path)
                target_path="$2"
                shift 2
                ;;
            --undo)
                print_warning "Undo functionality coming soon"
                exit 0
                ;;
            --log)
                if [[ -f "$LOG_FILE" ]]; then
                    tail -50 "$LOG_FILE"
                fi
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    check_dependencies
    load_config
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY-RUN MODE]${NC} No files will be moved"
    fi
    
    organize_by_type "$target_path"
    apply_rules
    
    if [[ "$DRY_RUN" == true ]]; then
        echo ""
        print_header "Ready to Execute?"
        echo "Preview complete. To execute changes, run:"
        echo -e "${GREEN}./file-butler.sh --execute${NC}"
    else
        print_success "Organization complete!"
        log "Organization completed successfully"
    fi
}

# Run main function
main "$@"
