#!/usr/bin/env bash
#
# Cross-check the two files that carry ClojureCLR's version, and optionally vet
# a release tag against them. Run from the repo root; PROPS_FILE / VERSION_FILE
# override the file locations. Prints k=v on stdout; exits 1 on any mismatch.

set -euo pipefail

usage() {
  cat <<'EOF'
usage: check-version.sh [--tag <name>]

  --tag <name>   Tag to validate. Must be clojure-<version> and must name the
                 version committed in the props files. Omit to only cross-check
                 the two files against each other.

Emits on stdout: full= suffix=
EOF
}

# Under Actions, prefix failures so they surface as annotations.
err() {
  if [ -n "${GITHUB_ACTIONS:-}" ]; then
    printf '::error::%s\n' "$*" >&2
  else
    printf 'error: %s\n' "$*" >&2
  fi
  exit 1
}

props="${PROPS_FILE:-Clojure/CurrentVersion.props}"
vpfile="${VERSION_FILE:-Clojure/Clojure/Bootstrap/version.properties}"

readonly tag_prefix='clojure-'
tag=''
tag_given=0

while [ $# -gt 0 ]; do
  case "$1" in
  --tag)
    # Check before shifting: `shift 2` with one arg left returns non-zero
    # without consuming anything, which under `set -e` exits silently -- and
    # without it, loops forever.
    [ $# -ge 2 ] || err "--tag requires a value, e.g. --tag ${tag_prefix}1.2.3"
    [ -n "$2" ] || err "--tag was given an empty value"
    tag="$2"
    tag_given=1
    shift 2
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    printf '\nunknown argument: %s\n' "$1" >&2
    exit 2
    ;;
  esac
done

[ -f "$props" ] || err "no such file: $props"
[ -f "$vpfile" ] || err "no such file: $vpfile"

xval() { sed -n "s|.*<$1>\([^<]*\)</$1>.*|\1|p" "$props" | head -n1 | tr -d '[:space:]'; }

major=$(xval MajorVersion)
minor=$(xval MinorVersion)
patch=$(xval PatchVersion)
suffix=$(xval VersionSuffix)

[ -n "$major" ] && [ -n "$minor" ] && [ -n "$patch" ] ||
  err "could not parse Major/Minor/PatchVersion out of $props"

if [ -n "$suffix" ]; then full="$major.$minor.$patch-$suffix"; else full="$major.$minor.$patch"; fi

# See docs/Preparing-a-release.md, "Preparation".
[ "$suffix" = "$(printf '%s' "$suffix" | tr '[:upper:]' '[:lower:]')" ] ||
  err "VersionSuffix '$suffix' must be lowercase (use rc1, not RC1)"

# Perl as POSIX ERE has no (?:) or \d.
command -v perl >/dev/null 2>&1 || err "perl is required to validate '$full' against the clojure.core regex for version"
core_re='(\d+)\.(\d+)\.(\d+)(?:-([a-zA-Z0-9_]+))?(?:-(SNAPSHOT))?'
CORE_RE="$core_re" FULL="$full" perl -e 'exit 1 unless $ENV{FULL} =~ /\A(?:$ENV{CORE_RE})\z/' ||
  err "version '$full' is not matched by the clojure.core version regex"

# version.properties is a single BOM-prefixed, newline-free line.
vp=$(tr -d '\r\n' <"$vpfile" | sed 's/^\xEF\xBB\xBF//; s/^version=//')
[ "$vp" = "$full" ] ||
  err "version mismatch -- $vpfile says '$vp', $props composes '$full'. Both are set by hand; see docs/Preparing-a-release.md, 'Preparation'."

if [ "$tag_given" -eq 1 ]; then
  case "$tag" in
  "$tag_prefix"*) tagver="${tag#"$tag_prefix"}" ;;
  *) err "tag '$tag' must start with '$tag_prefix', e.g. $tag_prefix$full" ;;
  esac
  [ "$tagver" = "$full" ] || err "tag '$tag' does not name the committed version '$full'"
fi

printf 'full=%s\n' "$full"
printf 'suffix=%s\n' "$suffix"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  printf '### ClojureCLR %s — tag `%s`\n' "$full" "${tag:-none}" >>"$GITHUB_STEP_SUMMARY"
fi
