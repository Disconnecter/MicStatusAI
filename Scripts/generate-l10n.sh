#!/usr/bin/env bash

set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
output_dir="${DERIVED_FILE_DIR:-$root/build/L10n}"

if ! command -v l10n-xcstrings >/dev/null 2>&1; then
  echo "error: L10nXcstrings not installed." >&2
  echo "Install with: brew install disconnecter/l10n/l10n_xcstrings" >&2
  exit 1
fi

mkdir -p "$output_dir"

l10n-xcstrings \
  --input "$root/MicStatusAI/Resources/Localizable.xcstrings" \
  --output-swift "$root/MicStatusAI/Generated/L10n.swift" \
  --output-unused "$output_dir/Unused.txt" \
  --source-dir "$root/MicStatusAI" \
  --ignore-dirs Generated \
  --table-name Localizable
