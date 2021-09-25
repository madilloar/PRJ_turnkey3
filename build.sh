#!/bin/bash
MYHOME=~/prj/turnkey3
TK3="turnkey-mvs-3"
CDROM="${MYHOME}/cdrom"

cd ${MYHOME}

if [ ! -e ${TK3}.zip ] ; then
  wget http://www.ibiblio.org/jmaynard/${TK3}.zip
  unzip ${TK3}.zip
fi

mkdir -p ${CDROM}
read -sp "Please sudo password:" PASSWORD
tty -s && echo
echo ${PASSWORD} | sudo -S mount -r ${TK3}.iso ${CDROM}

cp -r ${CDROM} ./src
echo ${PASSWORD} | sudo -S umount ${CDROM}
rm -rf ${CDROM}

chmod -R u+w ${MYHOME}/src/cdrom
rm -rf ${MYHOME}/src/media
mv ${MYHOME}/src/cdrom/ ${MYHOME}/src/media/

docker-compose build
