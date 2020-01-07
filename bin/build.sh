#!/bin/sh

cd "$GITHUB_WORKSPACE"/.apk/"$GITHUB_REPOSITORY" || exit

abuild snapshot
abuild -r
