#!/bin/sh

apk add --update curl git tar xz ca-certificates

git config --global user.name "Build Bot"
git config --global user.email "<>"

exec /build.sh
