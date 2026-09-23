// Hoist the chosen layout into the project root and drop the rest.
// Everything outside `layouts/` is shared by all four layouts.

let layout = variable::get("layout");
let name = variable::get("project-name");

let is_workspace = layout == "workspace" || layout == "members";
variable::set("is_workspace", is_workspace);

if layout == "bin" {
    file::rename("layouts/bin/src", "src");
    variable::set("crate_path", ".");
    variable::set("source_dir", "src");
} else if layout == "lib" {
    file::rename("layouts/lib/src", "src");
    variable::set("crate_path", ".");
    variable::set("source_dir", "src");
} else if layout == "workspace" {
    file::rename("layouts/workspace/crates", "crates");
    file::rename("crates/app", "crates/" + name);
    variable::set("members_glob", "crates/*");
    variable::set("crate_path", "crates/" + name);
    variable::set("source_dir", "crates");
} else {
    file::rename("layouts/members/app", name);
    variable::set("members_glob", name);
    variable::set("crate_path", name);
    variable::set("source_dir", name);
}

file::delete("layouts");

// LICENSE copyright year.
variable::set("year", "" + system::date().year);

// Consumed by Cargo.toml and the issue-template contact links.
variable::set("repository", "https://github.com/" + variable::get("gh_user") + "/" + name);
