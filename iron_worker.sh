#!/bin/bash -x

set -e

if [[ -e "env.sh" ]]; then
  source env.sh
fi

if [[ -e "id_rsa" ]]; then
  eval `ssh-agent`
  ssh-add id_rsa
fi

echo 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $*' > ssh
chmod +x ssh
export GIT_SSH="$(pwd)/ssh"

source ./build.sh
