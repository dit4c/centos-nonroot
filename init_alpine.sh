#!/bin/sh

apk add --update curl git tar xz

git config --global user.name "Build Bot"
git config --global user.email "<>"

cd /build
exec /build.sh
cd /

chown -R $CHOWN_TO /build
