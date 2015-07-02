#!/bin/bash +x

set -e

while true
do
  if [[ "$1" == "-config" ]]; then
    eval `ruby json_envvars_to_exports.rb < $2`
    shift
  elif [[ "$1" == "" ]]; then
    break
  else
    shift
  fi
done

if [[ -e "id_rsa" ]]; then
  eval `ssh-agent`
  ssh-add id_rsa
fi

echo 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $*' > ssh
chmod +x ssh
export GIT_SSH="$(pwd)/ssh"

bash +x ./build.sh
