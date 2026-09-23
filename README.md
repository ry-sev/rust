# rust

A [`cargo-generate`](https://github.com/cargo-generate/cargo-generate) template for
Rust projects, in four layouts.

## Usage

```bash
cargo install cargo-generate   # once
cargo generate ry-sev/rust
```

You are prompted for a layout:

| Value       | Shape                                              |
| ----------- | -------------------------------------------------- |
| `bin`       | Single crate, `src/main.rs`                        |
| `lib`       | Single crate, `src/lib.rs`                         |
| `workspace` | Virtual workspace, member at `crates/<name>/`      |
| `members`   | Virtual workspace, member at `<name>/` in the root |

...plus a description, author, and GitHub owner.

To skip the prompts:

```bash
cargo generate ry-sev/rust \
    --name my-project -d layout=workspace -d description="..."
```

The template itself lives in `template/`, selected automatically. Pass it
explicitly with `cargo generate ry-sev/rust template` if you ever need to.

## What you get

Every layout carries the same strict lint set, `rustfmt`/`clippy` configuration,
pinned toolchain, MIT license, GitHub issue templates, and an `AGENTS.md` describing
the project's conventions to coding agents.

See [AGENTS.md](AGENTS.md) for how the template is put together.

#### License

<sup>
Licensed under <a href="template/LICENSE.liquid">MIT license</a>.
</sup>
