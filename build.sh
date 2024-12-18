#!/bin/sh
echo SOURCECODEURL: "$SOURCECODEURL"
echo PKGNAME: "$PKGNAME"
echo BOARD: "$BOARD"
EMAIL=${EMAIL:-"aa@gmail.com"}
echo EMAIL: "$EMAIL"
echo PASSWORD: "$PASSWORD"

WORKDIR="$(pwd)"

sudo -E apt-get update
sudo -E apt-get install git  asciidoc bash bc binutils bzip2 fastjar flex gawk gcc genisoimage gettext git intltool jikespg libgtk2.0-dev libncurses5-dev libssl-dev make mercurial patch perl-modules python2.7-dev rsync ruby sdcc subversion unzip util-linux wget xsltproc zlib1g-dev zlib1g-dev -y

git config --global user.email "${EMAIL}"
git config --global user.name "aa"
[ -n "${PASSWORD}" ] && git config --global user.password "${PASSWORD}"

mkdir -p  ${WORKDIR}/buildsource
cd  ${WORKDIR}/buildsource
git clone "$SOURCECODEURL"
cd  ${WORKDIR}


mt7981_sdk_get()
{
	 git clone https://github.com/hanwckf/immortalwrt-mt798x.git  openwrt-sdk
}

case "$BOARD" in
       ;;
       "RAX3000M-EMMC" |\
       "RAX3000M-NAND" )
		      mt7981_sdk_get
       ;;
       *)
esac

cd openwrt-sdk
sed -i "1i\src-link githubaction ${WORKDIR}/buildsource" feeds.conf.default

ls -l
cat feeds.conf.default

./scripts/feeds update -a
./scripts/feeds install -a
echo CONFIG_ALL=y >.config
make defconfig
make V=s ./package/feeds/githubaction/${PKGNAME}/compile

find bin -type f -exec ls -lh {} \;
find bin -type f -name "*.ipk" -exec cp -f {} "${WORKDIR}" \; 
