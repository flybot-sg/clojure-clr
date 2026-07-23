# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

ClojureCLR is a native port of Clojure to the CLR (.NET). The runtime and compiler are written in C# (`clojure.lang.*`); the standard library (`clojure.core` and friends) is written in Clojure and lives in `Clojure/Clojure.Source/`. The overriding design goal is **fidelity to the JVM Clojure implementation** — code mirrors the upstream JVM source line-for-line wherever possible.

## Build & test

The canonical build is `Clojure/build.proj` (MSBuild), which drives the whole solution + test staging + run. **Run it through the .NET SDK's msbuild (`dotnet msbuild`), not the `msbuild` on PATH.**

```
cd Clojure
dotnet msbuild build.proj /t:Build                       # build the solution (Debug by default)
dotnet msbuild build.proj /t:Test                        # build, stage, and run the Clojure test suite
dotnet msbuild build.proj /t:Test /p:Configuration=Release
dotnet msbuild build.proj /t:Test /p:TestTargetFramework=net462   # target: net462 | netcoreapp3.1 | net5.0 | net6.0 (default net6.0)
dotnet msbuild build.proj /t:DeepClean                   # remove all bin/obj/Test/Stage output
dotnet msbuild build.proj /t:ListParams                  # print resolved build variables
```

### Toolchain requirements (verified on macOS/Apple-Silicon)

This repo targets **net6.0** for the default test flow, so the box needs the **.NET 6 SDK + runtime** installed alongside whatever newer SDK is present. Two gotchas, both handled:

- **Pin the SDK to 6.0** — a repo-root `global.json` pins `sdk.version` to `6.0.x`. This is required: under a newer default SDK (e.g. .NET 10) the `Test` target's `dotnet run -p …` invocation fails (`Couldn't find a project to run` — the `-p` shorthand for `--project` was broken/repurposed). With the pin, `dotnet msbuild build.proj /t:Test` builds every project (incl. the `net462` ones via the auto-restored reference-assembly package) and runs the suite on the native net6.0 runtime.
- **Do NOT use Homebrew Mono's `msbuild`** — its bundled SDK is too old and can't build net5.0/net6.0 (`error MSB3971: reference assemblies for ".NETFramework,Version=v6.0" were not found`). Mono is only needed to *run* the `net462` release artifacts (ILMerge/`Clojure.Main461`), which is a Windows-oriented flow anyway.

Per-project `dotnet build` also works for quick iteration (build TFMs `netcoreapp3.1`/`net5.0`/`net6.0` are EOL, so expect harmless `NETSDK1138` warnings):

```
cd Clojure
dotnet build Clojure/Clojure.csproj -c Debug                       # runtime+compiler → netstandard2.1 + net462
dotnet build Clojure.Main/Clojure.Main.csproj -c Debug -f net6.0   # REPL/script host
```

- `net462` is special: standard-library `.clj` files are AOT-compiled to DLLs (`Clojure.Compile`) and ILMerged into `Clojure.dll`. Non-`net462` targets load the library from source / embedded resources at startup.

### Running a REPL

```
cd Clojure
echo '(println (clojure-version))' | dotnet run --project Clojure.Main --framework net6.0 -c Debug   # prints "Clojure 1.11.0"
```

### Running the tests / a single test

`dotnet msbuild build.proj /t:Test` stages compiled output to `Clojure/Test/<Config>/<TFW>/`, copies in `run_test.clj`, and runs it — the runner discovers every namespace under `clojure/test_clojure/` and runs it via `clojure.test`. To run a **subset**, set `clojure.test-clojure.exclude-namespaces` to an EDN set of every *other* namespace (the runner runs discovered-minus-excluded). The `Test` target sets this itself to skip namespaces that don't apply to the framework (`genclass`/`attributes`/`compilation` on non-`net462`). For a single namespace, launch a REPL from the staged `Test/<Config>/<TFW>/` dir and `(require …)` + `(clojure.test/run-tests …)` it.

- **Note (fish shell):** env-var names with dots can't be set via `set -x`/`export`; prefix the command with `env 'clojure.test-clojure.exclude-namespaces=…'`.
- **Verified result (native net6.0, `dotnet msbuild build.proj /t:Test`):** `Ran 625 tests containing 17962 assertions. 0 failures, 0 errors.` (`test-expected-casts` in `numbers.clj` is platform-tolerant: out-of-range *unchecked* float→integer conversions are unspecified by ECMA-335 — x64/.NET<7 return the integer-indefinite sentinel, ARM64 and .NET≥7 saturate — so those cells accept either legal result.)
- **If `build.proj /t:Test` hangs** (build + AOT compile finish, then silence after the `dotnet run -p …` warnings, with no `Ran N tests` line): the Test target launches the suite via a *nested* `dotnet run`, whose implicit restore+build can deadlock on stale MSBuild build nodes / output-file locks left behind by earlier `dotnet run` REPL sessions. Fix: kill stray `MSBuild.dll`/`VBCSCompiler` processes (or `dotnet build-server shutdown`) first — or bypass the nesting entirely and run the already-staged suite directly: from `Test/<Config>/<TFW>/`, `env 'clojure.test-clojure.exclude-namespaces=…' dotnet Clojure.Main.dll run_test.clj` (use the same exclude set the `Test` target sets for the framework). This does no implicit build, so it can't hit the lock.

There are two test suites:
- **`Clojure.Tests/`** — the main suite: Clojure `deftest`s under `clojure/test_clojure/`, run via `run_test.clj` (and `run_test_generative.clj` for the `TestGen` target).
- **`Csharp.Tests/`** — NUnit tests (`ReaderTests/`, `LibTests/`) for the C# runtime internals. It multi-targets `netcoreapp3.1;net5.0;net6.0`, so pass `-f net6.0` to test only the framework whose runtime is installed: `dotnet test Csharp.Tests/Csharp.Tests.csproj -f net6.0` (without `-f` it also runs the EOL netcoreapp3.1/net5.0 legs, which need those runtimes). Verified cross-platform: `Passed: 898, Failed: 0`.

## Solution layout

`Clojure/Clojure.sln` contains:

| Project | Role |
|---|---|
| `Clojure` | The runtime + compiler (C#, `clojure.lang`). Also packages `Clojure.Source.dll`. Targets `netstandard2.1;net462`. |
| `Clojure.Source` | The `.clj` standard library, shipped as embedded resources. |
| `Clojure.Main` | REPL/script `Exe` entry point for modern .NET (`netcoreapp3.1;net5.0;net6.0`). Entry: `Clojure.Main/Main.cs`. |
| `Clojure.Main461` | Same entry point for `net462`. |
| `Clojure.Compile` | AOT compiler `Exe` (`net462`), used to pre-compile the library for the framework build. Entry: `Clojure.Compile/Compile.cs`. |
| `Clojure.Tests` | Clojure `clojure.test` suite. |
| `Csharp.Tests` | NUnit tests for C# internals. |
| `Clojure.Samples` | Example/sample code. |

Version is set in `Clojure/CurrentVersion.props`; shared MSBuild config (signing, configs, constants) in `Clojure/Directory.Build.props`.

## Runtime & compiler architecture (C#, `Clojure/Clojure/`)

- **`Lib/`** — the core runtime: data structures (`PersistentVector`, `PersistentHashMap`, `PersistentTreeMap`, `LazySeq`, `Cons`, …), the interface hierarchy (`IPersistentCollection`, `ISeq`, `IFn`, `IObj`, `Associative`, …), reference types (`Var`, `Atom`, `Ref`, `Agent`), numerics (`Numbers`, `BigInt`, `Ratio`, `BigDecimal`), the readers (`LispReader`, `EdnReader`), `Namespace`, `Symbol`, `Keyword`, and `RT` — the central runtime hub.
- **`CljCompiler/`** — the compiler. `Compiler.cs` drives read→analyze→emit; `CljCompiler/Ast/` has one file per AST node type (`Expr.cs` and all `*Expr.cs`), each responsible for its own IL emission. `GenClass`/`GenInterface`/`GenProxy`/`GenDelegate` handle `gen-class`/`deftype`/`proxy` codegen.
- **`Runtime/`** — CLR interop and hosting. `Reflector.cs` does reflective member access; `Runtime/Binding/` implements the DLR call-site binders (`ClojureInvokeMemberBinder`, etc.) used for dynamic interop. Built on the Microsoft `DynamicLanguageRuntime` package.
- **`Bootstrap/`**, `Properties/`, `Resources/`, `api/`, `Readers/` — startup, assembly metadata, embedded resources, public API surface, and low-level text readers (`LineNumberingTextReader`, `PushbackTextReader`).

`RT.Init()` bootstraps the runtime; the entry points then `require` `clojure.main`. See `docs/what-a-load-of-clojure.md` for the (intricate) load/compile algorithm — how `RT.load` searches for `.clj`/`.cljc` source vs `.clj.dll` assemblies vs `__INIT__<name>` types vs embedded resources.

## Standard library (`Clojure/Clojure.Source/clojure/`)

`core.clj` plus the usual namespaces (`string`, `set`, `pprint/`, `test`, `data`, `edn`, `walk`, `zip`, `datafy`, `reflect`, …). CLR-specific additions live in `core_clr.clj`, `clr/io.clj`, `clr/shell.clj`, and `reflect/clr.clj`.

### The JVM-parity convention (important)

The `.clj` and `.cs` sources are deliberately kept as close to the canonical JVM Clojure source as possible. In the `.clj` files a **trailing `;;;` comment preserves the original JVM code that was replaced**, e.g.:

```clojure
(throw (ArgumentException. ...))    ;;;IllegalArgumentException.
```

When porting or editing:
- Keep the diff from the JVM original minimal and localized.
- Preserve or add `;;;` trailing comments showing the JVM code you diverged from (`DM:` / author-initial notes flag intentional additions).
- Java types/methods map to CLR equivalents (`toString`→`ToString`, `IllegalArgumentException`→`ArgumentException`, `java.util.concurrent`→`System.Threading`, etc.).

## Conventions & gotchas

- Do **not** manually fix unbalanced parens in `.clj` files — run `clj-paren-repair <files>` (also formats with cljfmt).
- `.clj` source files use **CRLF** line endings, and `.cljfmt.edn` is `{:indentation? false}` (re-indentation is intentionally off to preserve the JVM-parity source style). When editing a `.clj`, keep the change minimal and CRLF-preserving — a tool/formatter that reflows the file or flips CRLF→LF produces a huge spurious diff. Verify with `git diff --stat` after editing; if line endings got stripped, `git checkout` the file and re-apply the edit with a line-preserving method (e.g. `perl -i`).
- CI (`.github/workflows/tests.yml`) runs **both** test suites on ubuntu/windows/macos on push/PR (macOS runners are ARM64; ubuntu/windows are x64) — cross-platform assumptions get exercised there.
- C# code matches ClojureJVM naming (e.g. `legacy_repl`) rather than .NET style in places; `IDE1006` naming warnings are intentionally suppressed for parity.
- `changes.md` is the changelog. Development happens on maintenance branches (e.g. `maint-1.11.x`); PRs generally target `master`.
- License headers (EPL-1.0) prefix every source file — keep them.
