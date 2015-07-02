#!/bin/sh -x

set -e

BASEDIR=`pwd`

CURRENT_IMAGE_LIST_SHA1=$(curl -s -L https://raw.githubusercontent.com/docker-library/official-images/master/library/centos | sha1sum | awk '{print $1}')
SHA1_FILE="imagelist.sha1"

git clone --single-branch git@github.com:dit4c/centos-notroot.git
if [[ $(cat centos-notroot/$SHA1_FILE) == "$CURRENT_IMAGE_LIST_SHA1" ]]; then
  echo "Image list hasn't changed. Nothing to do."
  exit 0
fi

mkdir -p tmp/rootfs

cd centos-notroot
git remote add official https://github.com/CentOS/sig-cloud-instance-images.git
git fetch official CentOS-7
git checkout -b CentOS-7-notroot FETCH_HEAD

curl -L http://portable.proot.me/proot-x86_64 > $BASEDIR/tmp/proot
chmod +x $BASEDIR/tmp/proot
TARBALL=`ls docker/*.tar.xz`
$BASEDIR/tmp/proot -0 tar xf $TARBALL -C $BASEDIR/tmp/rootfs --ignore-command-error
rm $TARBALL
# Add PRoot to image
chmod u+w $BASEDIR/tmp/rootfs/usr/sbin/
cp $BASEDIR/tmp/proot $BASEDIR/tmp/rootfs/usr/sbin/proot
chmod u-w $BASEDIR/tmp/rootfs/usr/sbin/
# Make all files readable as user
chmod -R u+r $BASEDIR/tmp/rootfs/
# Add placeholder user & group in image
$BASEDIR/tmp/rootfs/usr/sbin/proot -S $BASEDIR/tmp/rootfs /bin/bash -c \
  "groupadd -g 1000 notroot && useradd -g 1000 -N -u 1000 -M -d /root notroot"
# Tar up with new owner
tar cJ -C $BASEDIR/tmp/rootfs --owner=1000 --group=1000 -f $TARBALL .
# Remove maintainer and set new default user
sed -i '/^MAINTAINER.*$/d' docker/Dockerfile
echo "USER 1000" >> docker/Dockerfile
# Commit and squash to remove original tarball from history
git commit --fixup=$(git rev-parse HEAD) -a
GIT_SEQUENCE_EDITOR=/bin/true git rebase -i --autosquash --root
chmod -R +w $BASEDIR/tmp/rootfs && rm -rf $BASEDIR/tmp/rootfs

git checkout master
echo "$CURRENT_IMAGE_LIST_SHA1" > $SHA1_FILE
git commit -m "Updating image list digest" -a

git push origin master +CentOS-7-notroot
