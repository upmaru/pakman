#!/bin/sh

cd "$GITHUB_WORKSPACE"/.apk/"$GITHUB_REPOSITORY" || exit

abuild snapshot
abuild -r

sudo chown -R root:root "$GITHUB_WORKSPACE"
