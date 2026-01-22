#!/usr/bin/env python3
"""
link-profile.py - Link Claude configs based on profile definition.

Usage:
    python scripts/link-profile.py <profile>          # Link profile to default target
    python scripts/link-profile.py <profile> --target ~/.claude
    python scripts/link-profile.py --list             # List available profiles
    python scripts/link-profile.py <profile> --dry-run
"""

import argparse
import os
import sys
from pathlib import Path

import yaml


CONFIG_TYPES = ['skills', 'agents', 'mcps', 'hooks', 'commands', 'rules', 'prompts']


def load_profiles(repo_root: Path) -> dict:
    """Load profiles.yaml from repository root."""
    profiles_path = repo_root / 'profiles.yaml'
    if not profiles_path.exists():
        print(f"Error: {profiles_path} not found", file=sys.stderr)
        sys.exit(1)

    with open(profiles_path, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def resolve_profile(profiles_data: dict, profile_name: str) -> dict:
    """Resolve a profile, handling extends and include_all."""
    if profile_name not in profiles_data['profiles']:
        print(f"Error: Profile '{profile_name}' not found", file=sys.stderr)
        print(f"Available: {list(profiles_data['profiles'].keys())}", file=sys.stderr)
        sys.exit(1)

    profile = profiles_data['profiles'][profile_name].copy()

    # Handle extends
    if 'extends' in profile:
        base = resolve_profile(profiles_data, profile['extends'])
        for config_type in CONFIG_TYPES:
            base_items = base.get(config_type, [])
            profile_items = profile.get(config_type, [])
            profile[config_type] = list(set(base_items + profile_items))

    return profile


def get_all_configs(repo_root: Path) -> dict:
    """Get all available configs by type."""
    result = {}
    for config_type in CONFIG_TYPES:
        type_dir = repo_root / config_type
        if type_dir.exists():
            configs = []
            for item in type_dir.iterdir():
                if item.is_dir() and not item.name.startswith('.'):
                    if item.name == '_upstream':
                        # Check _upstream subdirectory
                        for upstream_item in item.iterdir():
                            if upstream_item.is_dir():
                                configs.append(f"_upstream/{upstream_item.name}")
                    else:
                        configs.append(item.name)
            result[config_type] = configs
    return result


def clean_symlinks(target_dir: Path, dry_run: bool = False):
    """Remove existing symlinks in target directory."""
    for config_type in CONFIG_TYPES:
        type_dir = target_dir / config_type
        if type_dir.exists():
            for item in type_dir.iterdir():
                if item.is_symlink():
                    if dry_run:
                        print(f"  [DRY-RUN] Would remove: {item}")
                    else:
                        item.unlink()
                        print(f"  Removed: {item}")


def create_symlinks(repo_root: Path, profile: dict, target_dir: Path, dry_run: bool = False):
    """Create symlinks for profile configs."""
    for config_type in CONFIG_TYPES:
        items = profile.get(config_type, [])
        if not items:
            continue

        target_type_dir = target_dir / config_type
        if not dry_run:
            target_type_dir.mkdir(parents=True, exist_ok=True)

        for item in items:
            src = repo_root / config_type / item
            # Determine destination name (strip _upstream/ prefix for cleaner target)
            dst_name = item.split('/')[-1] if '/' in item else item
            dst = target_type_dir / dst_name

            if not src.exists():
                print(f"  Warning: Source not found: {src}", file=sys.stderr)
                continue

            if dry_run:
                print(f"  [DRY-RUN] {dst} -> {src}")
            else:
                if dst.exists() or dst.is_symlink():
                    dst.unlink()
                dst.symlink_to(src, target_is_directory=True)
                print(f"  Linked: {dst} -> {src}")


def list_profiles(profiles_data: dict):
    """List all available profiles."""
    print("Available profiles:\n")
    for name, profile in profiles_data['profiles'].items():
        desc = profile.get('description', '')
        default_marker = ' (default)' if name == profiles_data.get('default') else ''
        print(f"  {name}{default_marker}")
        if desc:
            print(f"    {desc}")
        print()


def main():
    parser = argparse.ArgumentParser(description='Link Claude configs based on profile')
    parser.add_argument('profile', nargs='?', help='Profile name to activate')
    parser.add_argument('--target', '-t', help='Target directory (default: from profiles.yaml)')
    parser.add_argument('--list', '-l', action='store_true', help='List available profiles')
    parser.add_argument('--dry-run', '-n', action='store_true', help='Show what would be done')

    args = parser.parse_args()

    # Determine repo root (script is in scripts/)
    repo_root = Path(__file__).parent.parent.resolve()
    profiles_data = load_profiles(repo_root)

    if args.list:
        list_profiles(profiles_data)
        return

    if not args.profile:
        args.profile = profiles_data.get('default')
        if not args.profile:
            print("Error: No profile specified and no default set", file=sys.stderr)
            sys.exit(1)
        print(f"Using default profile: {args.profile}")

    # Resolve target directory
    target = args.target or profiles_data.get('target', '~/.claude')
    target_dir = Path(target).expanduser().resolve()

    print(f"Profile: {args.profile}")
    print(f"Target: {target_dir}")
    print()

    # Resolve profile (handle extends, include_all)
    profile = resolve_profile(profiles_data, args.profile)

    if profile.get('include_all'):
        all_configs = get_all_configs(repo_root)
        for config_type in CONFIG_TYPES:
            profile[config_type] = all_configs.get(config_type, [])

    # Clean and link
    print("Cleaning existing symlinks...")
    clean_symlinks(target_dir, args.dry_run)

    print("\nCreating symlinks...")
    create_symlinks(repo_root, profile, target_dir, args.dry_run)

    print("\nDone!")


if __name__ == '__main__':
    main()
