This file tracks changes made in the Flybot fork of ClojureCLR. Changes
inherited from upstream ClojureCLR are recorded in [changes.md](changes.md).

# Changes to ClojureCLR in Version 1.11.0-flybot1

## Fixes

Code originating in this fork. When a fix involves modifications to backported code, only
the modification is described here; the backported code is still under Backports.

* [#7](https://github.com/flybot-sg/clojure-clr/pull/7) `clojure.datafy/datafy`
  and `#object[...]` printing use fully-qualified class names (`.FullName`,
  matching JVM `.getName`) instead of the short `.Name`, so a datafied value
  records a name that resolves back to its class
* [#7](https://github.com/flybot-sg/clojure-clr/pull/7) `expected-casts`
  accepts either result for out-of-range unchecked float-to-integer
  conversions, which ECMA-335 leaves unspecified: x64 returns the
  integer-indefinite sentinel, ARM64 saturates. Upstream
  ([9d0a467d](https://github.com/clojure/clojure-clr/commit/9d0a467d)) splits
  the table on `dotnet-version` instead
* [#3](https://github.com/flybot-sg/clojure-clr/pull/3) Fixed cross-platform
  build and tests
* [#11](https://github.com/flybot-sg/clojure-clr/pull/11) `RT.load` probes
  embedded assembly resources with dot-separated names, which the slash-form
  names it looked for could never match
* [#12](https://github.com/flybot-sg/clojure-clr/pull/12) On a duplicate type
  name in namespace `System`, the default-import table prefers the core-library
  type (`typeof(object).Assembly`) over first-seen, so resolution no longer
  depends on assembly enumeration order
* [#12](https://github.com/flybot-sg/clojure-clr/pull/12) An assembly raising
  `ReflectionTypeLoadException` keeps the types that did load

## Backports

Code taken from ClojureCLR after 1.11.0. Each entry links the upstream commit
it came from. *(partial)* means only some hunks of that commit were taken.

### defn type-hint tags ([#7](https://github.com/flybot-sg/clojure-clr/pull/7))

* [CLJCLR-148](https://clojure.atlassian.net/browse/CLJCLR-148)
  ([3c34a383](https://github.com/clojure/clojure-clr/commit/3c34a383)) Tags on
  `defn` signatures are fully-qualified type-name symbols — `System.String`
  rather than `String`

### cljr CLI support ([#11](https://github.com/flybot-sg/clojure-clr/pull/11))

Backported so that dmiller's `cljr` CLI can run against a 1.11 `Clojure.Main`
([#8](https://github.com/flybot-sg/clojure-clr/issues/8)).

* [CLJCLR-123](https://clojure.atlassian.net/browse/CLJCLR-123)
  ([04c612fe](https://github.com/clojure/clojure-clr/commit/04c612fe)) Load
  `.cljr` source files, preferred over `.cljc` and `.clj`. Covers `RT.load` and
  its extension tables, the `.cljr` embedded-resource probe, the load-failure
  message, `user.cljr`, `data_readers.cljr`, the `.cljr` checks in
  `stack-element-str`, and the `DMDMDMDM` debug message in
  `Clojure.Compile.csproj`
* [CLJCLR-123 follow-up](https://clojure.atlassian.net/browse/CLJCLR-123)
  ([0433bb02](https://github.com/clojure/clojure-clr/commit/0433bb02)) `RT.load`
  derives `sourceName` from the extension of the file it found
* [CLJCLR-138](https://clojure.atlassian.net/browse/CLJCLR-138)
  ([a7b22653](https://github.com/clojure/clojure-clr/commit/a7b22653)) At
  startup, also look for `user.cljr` and `user.cljc`
* [CLJCLR-141](https://clojure.atlassian.net/browse/CLJCLR-141)
  ([1bb81947](https://github.com/clojure/clojure-clr/commit/1bb81947)) `RT.load`
  finds `.clj.dll` files under the dot-separated `dllRelativePath`
* [CLJCLR-133](https://clojure.atlassian.net/browse/CLJCLR-133)
  ([03f6cad5](https://github.com/clojure/clojure-clr/commit/03f6cad5)) Fix the
  semantics of `clojure.clr.io/as-file`; add `as-dir`, `file-info` and
  `dir-info`
* [CLJCLR-151](https://clojure.atlassian.net/browse/CLJCLR-151)
  ([cf3158f9](https://github.com/clojure/clojure-clr/commit/cf3158f9))
  *(partial)* Only the `(.EndsWith file ".cljr")` correction in
  `clojure.repl/stack-element-str`, which `04c612fe` left missing its `file`
  argument
* ([59a7fc15](https://github.com/clojure/clojure-clr/commit/59a7fc15))
  *(partial)* `Path/Combine` for `Path/Join` (absent on .NET Framework), and
  `DirectoryInfo` for the non-existent `DirInfo` tag. `clojure/clr/io.clj` only
  — see Known gaps
* [CLJCLR-153](https://clojure.atlassian.net/browse/CLJCLR-153)
  ([c8104f8d](https://github.com/clojure/clojure-clr/commit/c8104f8d)) Make
  `sys-action` handle zero type-args, previously expanding to the invalid type
  ``System.Action`0[]``
* [CLJCLR-154](https://clojure.atlassian.net/browse/CLJCLR-154)
  ([f2d27264](https://github.com/clojure/clojure-clr/commit/f2d27264)) Fix the
  repeated `.cljr` in the load-failure message
* [CLJCLR-155](https://clojure.atlassian.net/browse/CLJCLR-155)
  ([c6a94272](https://github.com/clojure/clojure-clr/commit/c6a94272)) Find
  `<namespace>.cljr` embedded resources in loaded assemblies
* [CLJCLR-156](https://clojure.atlassian.net/browse/CLJCLR-156)
  ([a26a136e](https://github.com/clojure/clojure-clr/commit/a26a136e))
  `gen-delegate` resolves the delegate type at macroexpansion and type-hints
  the formal parameters and the result
* ([004646ff](https://github.com/clojure/clojure-clr/commit/004646ff))
  *(partial)* Only the `RT.SystemRuntimeDirectory` field

### Type resolution ([#12](https://github.com/flybot-sg/clojure-clr/pull/12))

* ([125469b3](https://github.com/clojure/clojure-clr/commit/125469b3))
  *(partial)* Only the `CreateDefaultImportDictionary` rewrite that tolerates a
  duplicate type name instead of letting `ToDictionary` throw; the tie-break
  differs, see Fixes
* ([b4356d14](https://github.com/clojure/clojure-clr/commit/b4356d14)) Guard
  the assembly scan in `GetAllTypesInNamespace` so one unloadable assembly
  cannot abort it; the exception handling is narrower, see Fixes

### Known gaps

* [59a7fc15](https://github.com/clojure/clojure-clr/commit/59a7fc15) also
  replaces `Path/Join` with `Path/Combine` in `clojure/main.clj`. That hunk was
  not backported, so `clojure.main` still calls `Path/Join`, which does not
  exist on .NET Framework 4.6.2
