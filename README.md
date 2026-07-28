# ClojureCLR — Flybot fork

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

Publishing is a work in progress.
The current releases are `ILMerge`-d DLLs that can be used in Unity.

- `Clojure.dll` — the ILMerged assembly
- `Clojure.Source.dll`
- `Clojure.<version>.nupkg`

## Building from source

The build is unchanged from upstream — follow the
[ClojureCLR wiki](https://github.com/clojure/clojure-clr/wiki).

## License

    Copyright (c) Rich Hickey. All rights reserved. The use and
    distribution terms for this software are covered by the Eclipse
    Public License 1.0 (https://opensource.org/license/epl-1-0/)
    which can be found in the file epl-v10.html at the root of this
    distribution. By using this software in any fashion, you are
    agreeing to be bound by the terms of this license. You must
    not remove this notice, or any other, from this software.
