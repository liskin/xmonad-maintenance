#!/usr/bin/env bash

set -ex -o pipefail

git diff -U0 \
	--ignore-matching-lines='^#' \
	--word-diff=plain --word-diff-regex='@+|[^[:space:]@]+' \
	"$@" \
| while IFS= read -r l; do
	if [[ $l == @(diff|index|---|+++|@@)* ]]; then
		continue # diff header lines
	elif [[ $l =~ ^" "*"uses: ".*"@[-"(.*)"-]""{+"(.*)"+}" ]]; then
		rem_v="${BASH_REMATCH[1]}"
		add_v="${BASH_REMATCH[2]}"
		both_v="$rem_v"$'\n'"$add_v"
		if [[ $both_v == "$(sort --reverse --version-sort <<<"$both_v")" ]]; then
			continue # change to an older version
		fi
	fi

	exit 1 # any other change
done
