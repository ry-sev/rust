#!/usr/bin/env bash
# Generate every layout, plus variants with every option on, and check each.
# The template is not itself a Cargo project, so this is what keeps it honest.
#
# Optional tools run when installed: shellcheck, actionlint, cargo-deny, and nix.
# Set SKIP_NIX=1 to skip the Nix checks, which build every binary layout.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT

has() { command -v "$1" >/dev/null; }
nix_() { nix --extra-experimental-features 'nix-command flakes' "$@"; }

if has shellcheck; then
	shellcheck "${BASH_SOURCE[0]}"
else
	echo 'shellcheck not found, skipping'
fi

all=(-d cli=true -d async=true -d publish=true)

# name, layout, extra defines
cases=(
	"bin bin"
	"lib lib"
	"workspace workspace"
	"members members"
	"bin-all bin ${all[*]}"
	"workspace-all workspace ${all[*]}"
)

for case in "${cases[@]}"; do
	read -r name layout extra <<<"$case"
	printf '\n=== %s ===\n' "$name"

	# shellcheck disable=SC2086 # `extra` is a list of flags.
	cargo generate --path "$root/template" \
		--name "check-$name" \
		--destination "$out" \
		--define "layout=$layout" \
		--define "description=Template check" \
		--define "author=Template Check" \
		--define "gh_user=example" \
		$extra \
		--vcs none \
		--silent

	(
		cd "$out/check-$name"
		cargo fmt --all -- --check
		cargo clippy --all --all-features --tests -- -D warnings
		cargo test --all-features

		if [[ $layout != bin ]]; then
			RUSTDOCFLAGS='-D warnings' cargo doc --no-deps --all-features
		fi

		if has actionlint; then
			actionlint .github/workflows/*.yml
		fi

		if has cargo-deny; then
			cargo deny --log-level error check
		fi

		if has nix && [[ -z ${SKIP_NIX:-} ]]; then
			nix_ flake check
			nix_ develop --command cargo --version
			if [[ $layout != lib ]]; then
				nix_ build
				./result/bin/"check-$name"
			fi
		fi
	)
done

has actionlint || echo 'actionlint not found, skipped the workflow checks'
has cargo-deny || echo 'cargo-deny not found, skipped the deny checks'
if ! has nix; then
	echo 'nix not found, skipped the flake checks'
elif [[ -n ${SKIP_NIX:-} ]]; then
	echo 'SKIP_NIX set, skipped the flake checks'
fi

printf '\nall layouts ok\n'
