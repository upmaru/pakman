#!/bin/sh

cd "$GITHUB_WORKSPACE"/src/.apk/"$GITHUB_REPOSITORY" || exit

abuild snapshot
abuild -r
