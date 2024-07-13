#!/usr/bin/env nu

# Create a PR for the current commit
def 'jjpr create' [
  --draft (-d)
  --do-not-auto-tag (-t)
  --core-banking
  --change (-c): string = "@"
  --web (-w)
  --base (-b): string
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

# Update the current PR and its PR description
def 'jjpr update base' [
  --change (-c): string = "@"
  --base (-b): string
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

# Update the current PR and its PR description
def 'jjpr update desc' [
  --change (-c): string = "@"
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

# Update the current PR and its PR 
def 'jjpr view' [
  --change (-c): string = "@"
  --web (-w)
] {
  let head = _jjpr_branches $change | get 0;
 
  let web_arg = if ($web) { [ -w ] } else { [] };

  gh pr view $head ...$web_arg
}

def 'jjpr merge' [
  --change (-c): string = "@"
  --auto (-a)
  --squash (-s)
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
