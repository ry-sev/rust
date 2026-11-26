This repository is a `cargo-generate` template, not a Cargo project. Nothing here
compiles; `template/` is expanded into a new project by `cargo generate`.

## Layout

```
cargo-generate.toml       # Points cargo-generate at `template/`
scripts/check-templates.sh
template/
├── cargo-generate.toml   # Placeholders and hooks
├── pre-script.rhai       # Moves the chosen crates into place, derives variables
├── Cargo.toml.liquid     # Root manifest for every layout; all dependency versions
├── AGENTS.md.liquid      # Generated project's agent guide: `@` imports of docs/
├── docs/                 # CONTRIBUTING, development, code-style, releasing
├── README.md.liquid
├── LICENSE.liquid
├── .gitignore.liquid
├── clippy.toml, rustfmt.toml, rust-toolchain.toml, deny.toml, .gitattributes
├── flake.nix.liquid, .envrc  # Nix dev shell and package, loaded by direnv
├── .github/              # Workflows (not rendered), Dependabot, issue templates
└── crates/               # One source per crate kind
    ├── bin/              # Cargo.toml.liquid (workspace member), src/main.rs.liquid
    └── lib/              # Cargo.toml.liquid (workspace member), src/lib.rs.liquid
```

Everything outside `crates/` is shared by all five layouts. Files ending in
`.liquid` have the suffix stripped on generation.

## The Five Layouts

| Value           | Shape                                                       |
| --------------- | ----------------------------------------------------------- |
| `bin`           | Single crate, `src/main.rs`                                 |
| `lib`           | Single crate, `src/lib.rs`                                  |
| `workspace`     | Virtual workspace, `crates/<name>/` + `crates/<name>-core/` |
| `members`       | Virtual workspace, `<name>/` + `<name>-core/` in the root   |
| `lib-workspace` | Virtual workspace, a single library at `crates/<name>/`     |

Single-crate layouts take `src/` from `crates/bin` or `crates/lib` and use the root
manifest as their package. `workspace` and `members` take both crates with their member
manifests: the binary is named `<name>`, the library `<name>-core`. `lib-workspace`
takes only `crates/lib`, with its member manifest, as `crates/<name>/`; alone, the
library is named `<name>`.

## Placeholders

`layout`, `description`, `author`, `gh_user`, and `publish` are asked for every
layout. `cli` (clap) and `async` (tokio) are conditional placeholders, asked only
when the layout has a binary.

`pre-script.rhai` moves the crates into place, deletes the rest, and sets the
derived variables the templates branch on:

- `is_workspace` — true for `workspace`, `members`, and `lib-workspace`
- `has_bin`, `has_lib` — which crate kinds the project contains
- `cli`, `async` — set to `false` when not asked, so templates may test them freely
- `workspace_members` — the contents of the `workspace.members` array
- `lib_name` — the library's package name: `<name>-core` beside a binary, else `<name>`
- `lib_path` — path to the library crate, for its path dependency
- `lib_crate` — the library's Rust name, for doc tests and `use` paths
- `repository`, `year` — for the manifest, issue templates, and LICENSE

## Rules

- Lints live in **one** place: the single `[lints.rust]`/`[lints.clippy]` block in
  `template/Cargo.toml.liquid`. A liquid conditional swaps the table header to
  `[workspace.lints.*]` for workspace layouts. Never copy the block.
- Dependency versions live in **one** place: the dependency table in
  `template/Cargo.toml.liquid`, which becomes `[workspace.dependencies]` for
  workspace layouts. Member manifests reference them with `dep.workspace = true`.
- A change that is not layout-specific MUST go in a shared file, not in `crates/`.
- Every file is rendered by Liquid, `.liquid` suffix or not, unless `exclude` in
  `template/cargo-generate.toml` lists it. Liquid has no `not` operator.
- `.github/workflows/*` is excluded, because GitHub's `${{ }}` expressions break under
  Liquid. A workflow therefore MUST NOT need placeholders: it reads crate names, the
  version, binaries, and `rust-version` from `cargo metadata` at run time, so one file
  serves every layout.
- `CI passed` in `ci.yml` is the check generated repositories require before merging. A
  new job that checks the change MUST be added to its `needs`.
- Actions are pinned to commit hashes with the version in a comment. Resolve a tag with
  `git ls-remote --tags https://github.com/<owner>/<action>.git`, taking the `^{}` line
  for an annotated tag.
- The generated project's rules live in `template/docs/`, written for people.
  `AGENTS.md.liquid` lists them, with when each must be read, and holds the quick
  reference. Each entry is a bare `@docs/<file>.md` path: Claude Code expands it as an
  import, so the docs load with `AGENTS.md`, and other agents read it as a path. An
  `@path` inside backticks is not imported. A new rule goes in a doc, never in
  `AGENTS.md.liquid`. A new doc gets an entry in `AGENTS.md.liquid` and in
  `README.md.liquid`.
- There is no `CLAUDE.md`, here or generated. Claude Code reads `AGENTS.md` itself when
  no `CLAUDE.md` exists, and reads only `CLAUDE.md` when one does, so adding one would
  hide `AGENTS.md` unless it imports it.
- Symbolic links are skipped by `cargo-generate`. Use an `@file` import instead.
- A repository-level file MUST NOT share a name with a generated one. `ignore` in
  `cargo-generate.toml` drops the `.liquid` counterpart along with it, which is why
  the template lives in a subfolder.
- `sub_templates` has exactly one entry, so `cargo generate ry-sev/rust`
  selects it without prompting. Adding a second entry starts prompting and makes the
  subfolder argument part of the documented command.

## Verifying

```bash
./scripts/check-templates.sh
```

Generates all five layouts, plus `bin` and `workspace` with every option on, into a
temporary directory. Each runs `cargo fmt --check`, `cargo clippy -D warnings`,
`cargo test`, and `cargo doc` for library layouts. When installed, it also runs
shellcheck, actionlint on the generated workflows, `cargo deny check`, and the flake
(`nix flake check`, the dev shell, and `nix build` for binary layouts). `SKIP_NIX=1`
skips the Nix steps.

This MUST pass before committing; it is the only thing that type-checks the template.

To inspect one layout by hand:

```bash
cargo generate --path ./template --name scratch --destination /tmp -d layout=lib
```
