#!/usr/bin/env bash
# Works out the version, platform and archive name; writes them to $GITHUB_OUTPUT.
set -euo pipefail
REPO=matteopolak/jai

case "${RUNNER_OS:-}/${RUNNER_ARCH:-}" in
  Linux/X64) platform=linux-x64 ;;
  Linux/ARM64) platform=linux-arm64 ;;
  macOS/ARM64) platform=macos-arm64 ;;
  macOS/X64) platform=macos-x64 ;;
  Windows/X64) platform=windows-x64 ;;
  Windows/ARM64) platform=windows-arm64 ;;
  *) echo "::error::setup-jai does not support ${RUNNER_OS:-unknown}/${RUNNER_ARCH:-unknown}. Supported: Linux x64/arm64, macOS arm64/x64, Windows x64/arm64." >&2; exit 1 ;;
esac

version="${INPUT_VERSION:-latest}"
version="${version#v}"
if [ -z "$version" ] || [ "$version" = latest ]; then
  tag=""
  if body="$(curl -fsSL --retry 3 -H "Authorization: Bearer ${GH_TOKEN:-}" -H 'Accept: application/vnd.github+json' \
      "https://api.github.com/repos/$REPO/releases/latest" 2> /dev/null)"; then
    tag="$(printf '%s' "$body" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
  fi
  if [ -z "$tag" ]; then # API unavailable or rate limited: the redirect needs no quota
    url="$(curl -fsSL --retry 3 -o /dev/null -w '%{url_effective}' "https://github.com/$REPO/releases/latest")"
    tag="${url##*/}"
  fi
  version="${tag#v}"
fi
case "$version" in
  [0-9]*.[0-9]*.[0-9]*) ;;
  *) echo "::error::version '$version' is not 'latest' or a version like 0.4.3" >&2; exit 1 ;;
esac
case "$version" in *[!0-9A-Za-z.+-]*) echo "::error::invalid version '$version'" >&2; exit 1 ;; esac

# Releases up to 0.4.0 ship jaic-<platform>; later ones jai-<platform>.
if [ "$(printf '%s\n%s\n' "$version" 0.4.0 | sort -V | tail -n 1)" = 0.4.0 ]; then prefix=jaic; else prefix=jai; fi
ext=tar.gz
case "$platform" in windows-*) ext=zip ;; esac
temp="${RUNNER_TOOL_CACHE:-${RUNNER_TEMP:-/tmp}}"
{
  echo "version=$version"
  echo "platform=$platform"
  echo "root=$prefix-$platform"
  echo "archive=$prefix-$platform.$ext"
  echo "dir=$temp/setup-jai/$version/$platform"
} >> "$GITHUB_OUTPUT"
echo "Resolved Jai $version for $platform"
