// Move the crates the chosen layout needs into place and drop the rest.
// Everything outside `crates/` is shared by all five layouts.

let layout = variable::get("layout");
let name = variable::get("project-name");
let core = name + "-core";

let is_workspace = layout == "workspace" || layout == "members" || layout == "lib-workspace";
let has_bin = layout == "bin" || layout == "workspace" || layout == "members";
variable::set("is_workspace", is_workspace);
variable::set("has_bin", has_bin);
variable::set("has_lib", layout != "bin");

// Next to a binary the library is `<name>-core`; on its own it takes the project name.
let lib_name = if is_workspace && has_bin { core } else { name };
variable::set("lib_name", lib_name);

// `cli` and `async` are only prompted for layouts with a binary.
for flag in ["cli", "async"] {
    if !variable::is_set(flag) {
        variable::set(flag, false);
    }
}

if layout == "bin" {
    file::rename("crates/bin/src", "src");
    file::delete("crates");
} else if layout == "lib" {
    file::rename("crates/lib/src", "src");
    file::delete("crates");
} else if layout == "workspace" {
    file::rename("crates/lib", "crates/" + core);
    file::rename("crates/bin", "crates/" + name);
    variable::set("workspace_members", "\"crates/*\"");
    variable::set("lib_path", "crates/" + core);
} else if layout == "lib-workspace" {
    file::delete("crates/bin");
    file::rename("crates/lib", "crates/" + name);
    variable::set("workspace_members", "\"crates/*\"");
    variable::set("lib_path", "crates/" + name);
} else {
    file::rename("crates/lib", core);
    file::rename("crates/bin", name);
    file::delete("crates");
    variable::set("workspace_members", "\"" + name + "\", \"" + core + "\"");
    variable::set("lib_path", core);
}

// The library crate's Rust name, for doc tests and `use` paths.
let lib_crate = lib_name;
lib_crate.replace("-", "_");
variable::set("lib_crate", lib_crate);

// LICENSE copyright year.
variable::set("year", "" + system::date().year);

// Consumed by Cargo.toml and the issue-template contact links.
variable::set("repository", "https://github.com/" + variable::get("gh_user") + "/" + name);
