#!/bin/sh

repository=$(echo "$GITHUB_REPOSITORY" | sed -e 's/[^[:alnum:]]/-/g' | tr -s '-' | tr A-Z a-z)

cd "$GITHUB_WORKSPACE"/.apk/"$repository" || exit

abuild snapshot
abuild -r

sudo chown -R root:root "$GITHUB_WORKSPACE"
