#!/usr/bin/env bash

set -euo pipefail

destination="$1"

if [ -z "$destination" ]; then
    echo "Usage: $0 <destination>"
    exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Must set GITHUB_TOKEN environment variable"
    echo "Generate one at https://github.com/settings/personal-access-tokens/new"
    exit 1
fi

mkdir -p "$(dirname "$destination")"

user="$(curl -s \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/user \
    | jq -r .login)"

repo="dao-zmk-config"

curl -s \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$user/$repo/actions/artifacts \
    | jq '.artifacts[0].archive_download_url' \
    | xargs curl -sL \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/json" \
        -o "$destination"
