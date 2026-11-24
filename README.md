# rust

A [`cargo-generate`](https://github.com/cargo-generate/cargo-generate) template for
Rust projects, in four layouts.

## Usage

```bash
cargo install cargo-generate   # once
cargo generate ry-sev/rust
```

You are prompted for a layout:

| Value       | Shape                                                       |
| ----------- | ----------------------------------------------------------- |
| `bin`       | Single crate, `src/main.rs`                                 |
| `lib`       | Single crate, `src/lib.rs`                                  |
| `workspace` | Virtual workspace, `crates/<name>/` + `crates/<name>-core/` |
| `members`   | Virtual workspace, `<name>/` + `<name>-core/` in the root   |

Workspace layouts split a thin binary (`<name>`) from a library holding the logic
(`<name>-core`).

You are also asked for a description, author, GitHub owner, and whether to publish
to crates.io. Layouts with a binary additionally offer clap (`cli`) and tokio
(`async`).

To skip the prompts:

```bash
cargo generate ry-sev/rust \
    --name my-project -d layout=workspace -d description="..." -d cli=true
```

The template itself lives in `template/`, selected automatically. Pass it
explicitly with `cargo generate ry-sev/rust template` if you ever need to.

## What you get

Every layout carries:

- The same strict lint set and `rustfmt`/`clippy` configuration, plus documentation
  lints wherever there is a library
- `rust-toolchain.toml` as the single toolchain definition, read by rustup and Nix
- A Nix flake with a dev shell (loaded by direnv through `.envrc`) and, for layouts
  with a binary, a `nix build` package
- GitHub Actions CI (fmt, clippy, tests, docs, MSRV, `cargo deny`, and a weekly run
  against the latest dependencies), Dependabot, and issue templates
- A tag-triggered release workflow that drafts a GitHub release with categorized notes
  and, for layouts with a binary, executables for Linux, macOS, and Windows with their
  checksums; pull requests are labelled from their branch prefix
- A `docs/` folder for contributors: `CONTRIBUTING.md` (branches, merging),
  `development.md`, `code-style.md`, and `releasing.md`
- An `AGENTS.md` that points coding agents at those docs, which Claude Code loads as
  imports
- An MIT license

See [AGENTS.md](AGENTS.md) for how the template is put together.

#### License

<sup>
Licensed under <a href="template/LICENSE.liquid">MIT license</a>.
</sup>
