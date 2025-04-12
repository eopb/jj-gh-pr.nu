# jj-gh-pr.nu

[Nushell](https://www.nushell.sh/) command for quickly opening [Jujutsu](https://github.com/martinvonz/jj) PRs with [GitHub CLI](https://cli.github.com/).

```
> jj pr --help
Nushell command for opening Jujutsu PRs with GitHub

Usage:
  > jj pr

Subcommands:
  jj pr create (custom) - Create a PR for the current revision
  jj pr merge (custom) - Merge an open PR
  jj pr update base (custom) - Update a PRs base
  jj pr update desc (custom) - Update a PR description with revision details
  jj pr view (custom) - View details for a PR

Flags:
  -h, --help: Display the help message for this command

Input/output types:
  ╭───┬───────┬────────╮
  │ # │ input │ output │
  ├───┼───────┼────────┤
  │ 0 │ any   │ any    │
  ╰───┴───────┴────────╯
```

This script is opinionated and contains some flags that may only be useful to me.
If others want to contribute, I'm open to making the script more general.

## Usage

Add the `jjpr` command to your shell

```nu
source jjpr.nu
```

Run `jj pr`

```
jj pr --help
```
