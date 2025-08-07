#!/usr/bin/env -S nix shell nixpkgs#nushell --command nu

use update.nu

def commit_update []: nothing -> nothing {
  let zen_latest = update generate_sources

  git add -A
  let commit = git commit -m $"auto-update: ($zen_latest.prev_tag) -> ($zen_latest.new_tag)" | complete

  if ($commit.exit_code == 1) {
    print $"Latest version is ($zen_latest.prev_tag), no updates found"
  } else {
    print $"Performed update from ($zen_latest.prev_tag) -> ($zen_latest.new_tag)"
    print "Updating Flake lockfile"
    nix flake update --commit-lock-file

    let build = nix build | complete
    if ($build.exit_code == 0) {
      git push
    } else {
      print $"Update was successful, but there was a build failure! ($build.stderr). Not pushing update."
    }
  }
}

commit_update
