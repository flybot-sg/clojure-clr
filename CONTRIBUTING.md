# Contributing

This repo is Flybot's fork of [ClojureCLR](https://github.com/clojure/clojure-clr), carrying fixes on the 1.11.0 line. A patch meant for ClojureCLR itself goes through the [Clojure contributing guidelines](http://clojure.org/contributing); everything below is for this fork.

## Branches

`maint-1.11.x` is the fork's line and the default branch, and every PR targets it. `master` tracks upstream and takes no fork changes.

Branch from `maint-1.11.x`, named `<prefix>/<short-description>`, e.g. `fix/spit-truncate-append`.

## Filing issues

Phrase the title as a problem statement, not a solution or action.

- Good: `spit does not truncate an existing file, and :append is ignored`
- Bad: `Fix spit to truncate`

Body template:

    ## Problem

    What is wrong. A minimal reproducing code block. Symptoms, error messages, permalinks to the code.

    ## Suggestion

    Optional. The concrete change as a code block and why. Omit the section entirely if you have no concrete suggestion.

Show, don't describe: a minimal reproduction beats a paragraph. Name the runtime and framework you measured on.

## Pull requests

### Title

Same format as a commit title, one line:

    <prefix>(<scope>): <short description>

### Description

    Closes #<issue-number>
    ---

    - First change description
    - Second change description

Keep the bullets short; the issue carries the full context. A release PR has no issue to close and carries the release's `CHANGES_FLYBOT.md` section instead.

### Changelog entry

A PR with a user-facing change adds an entry to the unreleased section of [CHANGES_FLYBOT.md](./CHANGES_FLYBOT.md), in the same PR. Upstream's [changes.md](./changes.md) stays untouched.

- Under **Fixes** for code originating in this fork, linking the PR that carries it.
- Under **Backports** for code taken from ClojureCLR after 1.11.0, linking the upstream commit, marked *(partial)* when only some hunks were taken. 

Describe the change as a user meets it, the old symptom and the new behaviour, and match the style of the released sections.

### Before opening one

CI runs the test suites on Linux, Windows and macOS.

## Editing the ported sources

The `.clj` sources under `Clojure/Clojure.Source` are dmiller's port of Clojure, and the `;;;` comments trailing a line record the JVM original. Keep them. `cljfmt` is configured not to re-indent (`{:indentation? false}`), so match the formatting around you rather than reformatting.

## Commits

We follow [Conventional Commits](https://www.conventionalcommits.org/):

    <prefix>(<scope>): <description>

Common prefixes: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`. Keep the title to one line; details belong in the PR description.

Keep the body to a few plain sentences: the what and the non-obvious why. Do not list the files touched, narrate the steps taken, or report test results; the diff and CI already show those. LLM-generated messages tend to include all three, so trim them before committing.

Reference the related issue in the title or body, e.g. `(#42)` or `Closes #42`. Issue references belong in commit messages and PR descriptions only, never in source files or comments: trackers migrate, and in-code numbers go stale.

## Releasing

See [docs/Preparing-a-release.md](./docs/Preparing-a-release.md).
