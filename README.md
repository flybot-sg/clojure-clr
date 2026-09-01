# Flybot fork of ClojureCLR

A fork of [ClojureCLR](https://github.com/clojure/clojure-clr) maintained by
Flybot to backport fixes from ClojureCLR 1.12 onto the 1.11.0 line. See
[readme.txt](readme.txt) for the original project description.

[MAGIC](https://github.com/flybot-sg/magic), Flybot's custom Clojure-to-CIL
AOT compiler for Unity, currently targets Clojure 1.10. We base this fork on
1.11.0 rather than 1.10 because 1.11.0 already carries fixes we need, and it
is the version MAGIC is being brought up to parity with.

## What's changed

See [CHANGES_FLYBOT.md](CHANGES_FLYBOT.md). Upstream's own changelog,
[changes.md](changes.md), is unchanged.

## Releases

Pushing a `clojure-<version>` tag runs
[`.github/workflows/release.yml`](.github/workflows/release.yml), which builds and
tests net462, then publishes a GitHub Release whose notes are the matching
`CHANGES_FLYBOT.md` section. See
[docs/Preparing-a-release.md](docs/Preparing-a-release.md) for the steps it needs
beforehand, and for the zips and the NuGet push it does not cover. Each release
carries:

- `Clojure.dll`: the net462 `ILMerge`-d assembly. The runtime, compiler
  and 39 standard-library namespaces are AOT-compiled into this. Use this in
  Unity.
- `Clojure.Source.dll`: the standard library as embedded `.clj` resources,
  used by `Clojure.Compile` to produce the AOT assemblies merged into
  `Clojure.dll` above.
- `clojure.spec.alpha.dll`, `clojure.core.specs.alpha.dll`,
  `Microsoft.Dynamic.dll`, `Microsoft.Scripting.dll` and
  `Microsoft.Scripting.Metadata.dll`: NuGet dependencies, not merged into
  `Clojure.dll`. Place the DLLs side-by-side: `clojure.core` loads specs at startup,
  and the DLR assemblies back CLR interop.
- `Clojure.<version>.nupkg`: the NuGet package, which resolves those
  dependencies itself.
- `Clojure.Main.<version>.nupkg`: the `Clojure.Main` .NET tool. Install it with
  `dotnet tool install clojure.main --version <version> --add-source <dir>` to
  put this fork's runtime on PATH, which is how dmiller's `cljr` CLI picks the
  runtime it invokes.

## Contributing

Branch, issue, PR, commit and changelog conventions are in
[CONTRIBUTING.md](CONTRIBUTING.md).

## Building from source

For the build process, see the
[ClojureCLR wiki](https://github.com/clojure/clojure-clr/wiki).

## License

    Copyright (c) Rich Hickey. All rights reserved. The use and
    distribution terms for this software are covered by the Eclipse
    Public License 1.0 (https://opensource.org/license/epl-1-0/)
    which can be found in the file epl-v10.html at the root of this
    distribution. By using this software in any fashion, you are
    agreeing to be bound by the terms of this license. You must
    not remove this notice, or any other, from this software.
