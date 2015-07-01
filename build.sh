#!/bin/sh

BASEDIR=`pwd`

mkdir -p tmp/rootfs

git clone --single-branch https://github.com/CentOS/sig-cloud-instance-images.git
cd sig-cloud-instance-images
git fetch origin CentOS-7
git checkout -b CentOS-7-noroot FETCH_HEAD

TARBALL=`ls docker/*.tar.xz`
tar xf $TARBALL -C ../tmp/rootfs
rm $TARBALL
# Add PRoot to image
curl -L http://portable.proot.me/proot-x86_64 > ../tmp/rootfs/usr/sbin/proot
chmod +x ../tmp/rootfs/usr/sbin/proot
# Add placeholder user & group in image
../tmp/rootfs/usr/sbin/proot -S ../tmp/rootfs /bin/bash -c \
  "groupadd -g 1000 notroot && useradd -g 1000 -N -u 1000 -M -d /root notroot"
# Remove setuid & setgid flags
find tmp/rootfs -perm +4000 -xdev -not -type f -exec chmod u-s {} \;
find tmp/rootfs -perm +2000 -xdev -type f -exec chmod g-s {} \;
# Tar up with new owner
tar c -C ../tmp/rootfs --owner=1000 --group=1000 -f $TARBALL .
git commit -m "fixup!" -a
GIT_SEQUENCE_EDITOR=/bin/true git rebase -i --autosquash --root
rm -rf ../tmp/rootfs

# Remove maintainer and set new default user
sed -i '/pattern to match/d' docker/Dockerfile
echo "USER 1000" >> docker/Dockerfile
