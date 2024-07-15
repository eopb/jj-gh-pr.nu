#!/usr/bin/env nu

# Nushell command for opening Jujutsu PRs with GitHub
def 'jj pr' [] {
  help jj pr
}

# Create a PR for the current revision
def 'jj pr create' [
  --change (-c): string = "@" # Revision to include as head of PR
  --base (-b): string # Defaults to the parent of `--change`
  --draft (-d) # Open PR in draft
  --web (-w) # Open the PR in a browser after it is opened
  --do-not-auto-tag (-t) # Add label `do-not-auto-tag`
  --core-banking # Add label `core-banking`
] {
  jj git push -c $change;
  let head = _jjpr_branches $change | get 0;

  let base = if ($base == null) {
    _jjpr_base $change
  } else {
    $base
  };

  let draft_arg = if ($draft) { [ -d ] } else { [] };
  let auto_tag_arg = if ($do_not_auto_tag) { [ -l do-not-auto-tag ] } else { [] };
  let core_banking_arg = if ($core_banking) { [ -l core-banking ] } else { [] };

  gh pr create ...$draft_arg ...$auto_tag_arg ...$core_banking_arg -f -H $head -B $base

  if ($web) {
    gh pr view $head -w
  }
}

# Update a PRs base
def 'jj pr update base' [
  --change (-c): string = "@" # Head of PR
  --base (-b): string # New base. Defaults to the parent of `--change`
] {
  jj git push -c $change;
  let head = _jjpr_branches $change | get 0;

  let base = if ($base == null) {
    _jjpr_base $change
  } else {
    $base
  };

  gh pr edit $head -B $base
}

# Update a PR description with revision details
def 'jj pr update desc' [
  --change (-c): string = "@" # Head of PR
] {
  jj git push -c $change;
  let description = _jjpr_template_rev 'description' $change;

  let lines = $description
    | lines
    | skip while {|line| $line == ""};

  let title = $lines | get 0;

  let body = $lines
    | skip 1
    | skip while {|line| $line == ""}
    | str join "\n";

  let head = _jjpr_branches $change | get 0;

  gh pr edit $head -t $title -b $body
}

# View details for a PR
def 'jj pr view' [
  --change (-c): string = "@" # Head of PR
  --web (-w) # View PR in browser
] {
  let head = _jjpr_branches $change | get 0;
 
  let web_arg = if ($web) { [ -w ] } else { [] };

  gh pr view $head ...$web_arg
}

# Merge an open PR
def 'jj pr merge' [
  --change (-c): string = "@" # Head of PR
  --auto (-a) # Enable auto-merge
  --squash (-s) # Merge with squash rather than rebase
] {
  let head = _jjpr_branches $change | get 0;
 
  let auto_arg = if ($auto) { [ --auto ] } else { [] };
  let squash_arg = if ($squash) { [ -s ] } else { [ -r ] };

  gh pr merge $head ...$auto_arg ...$squash_arg -d
}

def _jjpr_template_rev [template: string rev: string] {
  jj log --color never --revisions $rev --no-graph --template $template --ignore-working-copy
}

def _jjpr_base [change: string] {
  let parent = $change + '-';
  _jjpr_branches $parent | get 0
}

def _jjpr_branches [rev: string] {
  _jjpr_template_rev 'branches' $rev
    | split row ' '
    # Remove `*` not yet pushed prefix
    | each {|branch| $branch | str trim --right --char '*' }
}
