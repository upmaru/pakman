#!/bin/sh

cd "$GITHUB_WORKSPACE"/.apk/"$GITHUB_REPOSITORY" || exit

abuild snapshot

export RPATH=/usr/lib

abuild -r

sudo chown -R root:root "$GITHUB_WORKSPACE"
