commit="$( git rev-parse "${1:?Commit ID Required}" )" || exit 1
printf "%s" "${commit}" > .target
git cat-file blob "${commit}:deps.tgf" > deps.tgf
git cat-file blob "${commit}:deps.tgf" | grep -vF " weak:test" > deps_notest.tgf
