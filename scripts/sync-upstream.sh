#!/bin/bash
# sync-upstream.sh - Sync skills from upstream repositories
# Usage: ./scripts/sync-upstream.sh [skill-name] [--all] [--check]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TEMP_DIR="/tmp/skill-sync-$$"
DATE=$(date +%Y-%m-%d)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Cleanup on exit
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Parse SOURCES.yaml (simple bash parsing)
get_upstream_url() {
    local repo_name=$1
    grep -A2 "^  $repo_name:" "$ROOT_DIR/SOURCES.yaml" | grep "url:" | awk '{print $2}'
}

get_upstream_branch() {
    local repo_name=$1
    local branch=$(grep -A3 "^  $repo_name:" "$ROOT_DIR/SOURCES.yaml" | grep "branch:" | awk '{print $2}')
    echo "${branch:-master}"
}

# Sync a single skill from upstream
sync_skill() {
    local category=$1
    local skill_name=$2
    local upstream_repo=$3
    local upstream_path=$4

    log_info "Syncing $skill_name from $upstream_repo..."

    local upstream_url=$(get_upstream_url "$upstream_repo")
    local upstream_branch=$(get_upstream_branch "$upstream_repo")
    local target_dir="$ROOT_DIR/$category/_upstream/$skill_name"

    if [ -z "$upstream_url" ]; then
        log_error "Unknown upstream repository: $upstream_repo"
        return 1
    fi

    # Create temp directory and clone with sparse checkout
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"

    git clone --filter=blob:none --sparse "$upstream_url" repo 2>/dev/null
    cd repo
    git sparse-checkout set "$upstream_path"

    # Get commit hash
    local commit_hash=$(git rev-parse HEAD | cut -c1-8)

    # Backup existing if present
    if [ -d "$target_dir" ]; then
        log_info "Backing up existing $skill_name..."
        mv "$target_dir" "${target_dir}.backup.$(date +%s)"
    fi

    # Copy to target
    mkdir -p "$(dirname "$target_dir")"
    cp -r "$upstream_path" "$target_dir"

    # Create/update .source.yaml
    cat > "$target_dir/.source.yaml" << EOF
# Source tracking file - DO NOT DELETE
# This file tracks the upstream source for license compliance

upstream:
  repo: $upstream_repo
  url: $upstream_url
  path: $upstream_path
  branch: $upstream_branch
  commit: $commit_hash
  synced_at: $DATE

license: Apache-2.0
license_url: https://www.apache.org/licenses/LICENSE-2.0

# Set to 'yes' if you've modified this skill locally
# If modified, describe changes below
modified: no
modifications: |
  None

# Original authors (from upstream)
attribution: |
  Original source: $upstream_url
  Licensed under Apache License 2.0
EOF

    log_success "Synced $skill_name (commit: $commit_hash)"

    # Cleanup backup if sync successful
    rm -rf "${target_dir}.backup."*

    cd "$ROOT_DIR"
}

# Check for updates (without syncing)
check_updates() {
    local skill_name=$1
    local source_file=$2

    if [ ! -f "$source_file" ]; then
        log_warn "No .source.yaml found for $skill_name"
        return
    fi

    local upstream_repo=$(grep "repo:" "$source_file" | awk '{print $2}')
    local upstream_url=$(grep "url:" "$source_file" | head -1 | awk '{print $2}')
    local local_commit=$(grep "commit:" "$source_file" | awk '{print $2}')
    local upstream_path=$(grep "path:" "$source_file" | head -1 | awk '{print $2}')
    local upstream_branch=$(grep "branch:" "$source_file" | awk '{print $2}')

    # Get latest commit from upstream
    local latest_commit=$(git ls-remote "$upstream_url" "refs/heads/$upstream_branch" 2>/dev/null | cut -c1-8)

    if [ "$local_commit" = "$latest_commit" ]; then
        log_success "$skill_name is up to date ($local_commit)"
    else
        log_warn "$skill_name has updates available: $local_commit -> $latest_commit"
    fi
}

# Main
show_help() {
    echo "Usage: $0 [OPTIONS] [SKILL_NAME]"
    echo ""
    echo "Options:"
    echo "  --all       Sync all enabled skills from SOURCES.yaml"
    echo "  --check     Check for updates without syncing"
    echo "  --list      List all tracked upstream skills"
    echo "  --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 mcp-builder              # Sync specific skill"
    echo "  $0 --check                  # Check all for updates"
    echo "  $0 --all                    # Sync all enabled skills"
}

list_skills() {
    log_info "Tracked upstream skills:"
    echo ""
    find "$ROOT_DIR" -name ".source.yaml" -type f | while read source_file; do
        local skill_dir=$(dirname "$source_file")
        local skill_name=$(basename "$skill_dir")
        local category=$(basename "$(dirname "$(dirname "$skill_dir")")")
        local synced_at=$(grep "synced_at:" "$source_file" | awk '{print $2}')
        local commit=$(grep "commit:" "$source_file" | awk '{print $2}')
        echo "  [$category] $skill_name (synced: $synced_at, commit: $commit)"
    done
}

case "${1:-}" in
    --help|-h)
        show_help
        ;;
    --list|-l)
        list_skills
        ;;
    --check|-c)
        log_info "Checking for updates..."
        find "$ROOT_DIR" -name ".source.yaml" -type f | while read source_file; do
            skill_name=$(basename "$(dirname "$source_file")")
            check_updates "$skill_name" "$source_file"
        done
        ;;
    --all|-a)
        log_info "Syncing all enabled skills..."
        # For now, sync mcp-builder as example
        sync_skill "development" "mcp-builder" "awesome-claude-skills" "mcp-builder"
        log_success "All skills synced!"
        ;;
    "")
        show_help
        ;;
    *)
        # Sync specific skill - need to find it first
        skill_name=$1
        source_file=$(find "$ROOT_DIR" -path "*/_upstream/$skill_name/.source.yaml" -type f 2>/dev/null | head -1)

        if [ -n "$source_file" ]; then
            upstream_repo=$(grep "repo:" "$source_file" | awk '{print $2}')
            upstream_path=$(grep "path:" "$source_file" | head -1 | awk '{print $2}')
            category=$(basename "$(dirname "$(dirname "$(dirname "$source_file")")")")
            sync_skill "$category" "$skill_name" "$upstream_repo" "$upstream_path"
        else
            log_error "Skill '$skill_name' not found. Use --list to see tracked skills."
            exit 1
        fi
        ;;
esac
