#!/usr/bin/env bash

set -ex -o pipefail

ghc_versions=$(
	curl -LSsf https://raw.githubusercontent.com/haskell-actions/setup/main/src/versions.json \
	| jq -r '.ghc[]' \
	| sort --version-sort --reverse \
	| sort --version-sort --field-separator=. --key=1,2 --unique
)
ghc_oldest_full=$(grep '^tested-with:' ./*.cabal | grep -P -o 'GHC == \K\d+\.\d+\.\d+' | head -1)
ghc_oldest="${ghc_oldest_full%.*}"
ghc_oldest_newpatch=$(<<<"$ghc_versions" grep "^${ghc_oldest/./\\.}\.")
tested_with=$(<<<"$ghc_versions" xargs printf ' || == %s' | sed "s/.*${ghc_oldest/./\\.}/GHC == $ghc_oldest/")
sed -i "s/^\(tested-with:\s*\).*/\1${tested_with}/" ./*.cabal
sed -i "s/${ghc_oldest_full/./\\.}/${ghc_oldest_newpatch}/g" ./*.cabal
