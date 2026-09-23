#!/usr/bin/env bash
# Generate every layout and run the full check suite on each.
# The template is not itself a Cargo project, so this is what keeps it honest.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT

for layout in bin lib workspace members; do
	printf '\n=== %s ===\n' "$layout"

	cargo generate --path "$root/template" \
		--name "check-$layout" \
		--destination "$out" \
		--define "layout=$layout" \
		--define "description=Template check" \
		--define "author=Template Check" \
		--define "gh_user=example" \
		--vcs none \
		--silent

	(
		cd "$out/check-$layout"
		cargo fmt --all -- --check
		cargo clippy --all --all-features --tests -- -D warnings
		cargo test
	)
done

printf '\nall layouts ok\n'
