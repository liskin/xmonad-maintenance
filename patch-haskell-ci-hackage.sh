#!/usr/bin/env bash

set -ex -o pipefail
shopt -s lastpipe

git diff -U0 origin/HEAD -- ./*.cabal \
| grep '^.tested-with:' \
| { read -r tested_with_old && read -r tested_with_new; } \
|| exit 0
[[ $tested_with_old && $tested_with_new ]] || exit 0

paste \
	<(grep '^-tested-with:' <<<"$tested_with_old" | grep -P -o '== \K\d+\.\d+\.\d+') \
	<(grep '^+tested-with:' <<<"$tested_with_new" | grep -P -o '== \K\d+\.\d+\.\d+') \
| while read -r v1 v2; do
	if [[ $v1 && $v2 ]]; then
		sed -i "s/\\([ -]\\)${v1}/\\1${v2}/" .github/workflows/haskell-ci-hackage.patch
	fi
done
