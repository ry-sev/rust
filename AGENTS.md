This repository is a `cargo-generate` template, not a Cargo project. Nothing here
compiles; `template/` is expanded into a new project by `cargo generate`.

## Layout

```
cargo-generate.toml       # Points cargo-generate at `template/`
scripts/check-templates.sh
template/
├── cargo-generate.toml   # Placeholders and hooks
├── pre-script.rhai       # Hoists the chosen layout, derives variables
├── Cargo.toml.liquid     # Root manifest for every layout
├── AGENTS.md.liquid      # Generated project's agent guide
├── README.md.liquid
├── LICENSE.liquid
├── .gitignore.liquid
├── CLAUDE.md             # `@AGENTS.md` import
├── clippy.toml, rustfmt.toml, rust-toolchain.toml, .gitattributes, .github/
└── layouts/              # The only per-layout files
    ├── bin/src/main.rs
    ├── lib/src/lib.rs.liquid
    ├── workspace/crates/app/
    └── members/app/
```

Everything outside `layouts/` is shared by all four layouts. Files ending in
`.liquid` have the suffix stripped on generation.

## The Four Layouts

| Value       | Shape                                             |
| ----------- | ------------------------------------------------- |
| `bin`       | Single crate, `src/main.rs`                       |
| `lib`       | Single crate, `src/lib.rs`                        |
| `workspace` | Virtual workspace, member at `crates/<name>/`     |
| `members`   | Virtual workspace, member at `<name>/` in the root |

`pre-script.rhai` moves the chosen directory out of `layouts/`, deletes the rest,
and sets the derived variables the templates branch on:

- `is_workspace` — true for `workspace` and `members`
- `members_glob` — the `workspace.members` entry
- `crate_path` — path to the primary crate, for `cargo run -p`
- `source_dir` — top-level source directory, for `.gitignore`
- `repository`, `year` — for the manifest, issue templates, and LICENSE

## Rules

- Lints live in **one** place: the single `[lints.rust]`/`[lints.clippy]` block in
  `template/Cargo.toml.liquid`. A liquid conditional swaps the table header to
  `[workspace.lints.*]` for workspace layouts. Never copy the block.
- A change that is not layout-specific MUST go in a shared file, not in `layouts/`.
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

Generates all four layouts into a temporary directory and runs `cargo fmt --check`,
`cargo clippy -D warnings`, and `cargo test` on each. This MUST pass before committing;
it is the only thing that type-checks the template.

To inspect one layout by hand:

```bash
cargo generate --path ./template --name scratch --destination /tmp -d layout=lib
```
