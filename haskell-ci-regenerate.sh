#!/usr/bin/env bash

set -ex -o pipefail

tested_with_versions=$(grep '^tested-with:' ./*.cabal | grep -P -o '== \K\d+\.\d+\.\d+' | xargs)
haskell_ci_output=$(haskell-ci regenerate 2>&1)
haskell_ci_versions=$(<<<"$haskell_ci_output" grep -P -o '^\*INFO\*.*for GHC versions:\s+\K.*')

[[ "$tested_with_versions" == "$haskell_ci_versions" ]]
