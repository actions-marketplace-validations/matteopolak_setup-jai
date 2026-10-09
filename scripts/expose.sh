#!/usr/bin/env bash
# Puts the chosen tools on PATH, points JAIC_STDLIB at the stdlib, writes the outputs.
set -euo pipefail

root="$DIR/$ROOT"
exe=""
case "${RUNNER_OS:-}" in Windows) exe=.exe ;; esac

tools="$(printf '%s' "${INPUT_TOOLS:-all}" | tr ',' ' ' | tr 'A-Z' 'a-z')"
[ -n "${tools// /}" ] || tools=all
case " $tools " in *" all "*) tools="jaic jaifmt jailint jailsp" ;; esac
for t in $tools; do
  case "$t" in
    jaic | jaifmt | jailint | jailsp) ;;
    *) echo "::error::unknown tool '$t'; choose from jaic, jaifmt, jailint, jailsp, or all" >&2; exit 1 ;;
  esac
done

# One folder holding exactly the chosen tools, linked to the unpacked release so each
# still finds its stdlib; the whole release folder is used for "all".
bindir="$root"
want="$(printf '%s\n' $tools | sort -u | tr '\n' ' ')"
if [ "$want" != "jaic jaifmt jailint jailsp " ]; then
  bindir="$DIR/bin"
  rm -rf "$bindir"
  mkdir -p "$bindir"
  export MSYS=winsymlinks:nativestrict
  for t in $want; do
    if [ ! -e "$root/$t$exe" ]; then
      echo "::error::Jai $VERSION does not ship $t" >&2
      exit 1
    fi
    if ! ln -s "$root/$t$exe" "$bindir/$t$exe" 2> /dev/null; then
      echo "::warning::could not link $t; putting the whole release folder on PATH instead"
      bindir="$root"
      break
    fi
  done
fi

out_path="$bindir"
stdlib="$root/stdlib"
if [ "${RUNNER_OS:-}" = Windows ]; then out_path="$(cygpath -w "$bindir")"; stdlib="$(cygpath -w "$stdlib")"; fi
echo "$out_path" >> "$GITHUB_PATH"
echo "JAIC_STDLIB=$stdlib" >> "$GITHUB_ENV"
{ echo "version=$VERSION"; echo "path=$out_path"; } >> "$GITHUB_OUTPUT"
echo "Jai $VERSION: $want on PATH ($out_path)"
