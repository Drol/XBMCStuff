#!/bin/bash
NUMPARAMS=1

if [ $# -lt "$NUMPARAMS" ]
then
	echo
	echo "Usage: $0 <upgrade / refresh>"
	echo
	echo "-- UPGRADE = MUST RUN FIRST (& ONLY ONCE) - (Setup build environment and install required Dependencies, then DOWNLOADS XBMC GIT)"
	echo "-- refresh = RUN THEREAFTER to update existing XBMC GIT COMPILE to latest version"
	echo
else

S1="upgrade"
S2="refresh"

	if [ $1 = $S1 ]
	then
		stop xbmc-live
		
		#Install libspotify
		mkdir ~/libspotify
		cd $HOME/libspotify
		if $(uname -a | grep 'x86_64'); then
			echo "Installing 64-bit libspotify"
			wget http://developer.spotify.com/download/libspotify/libspotify-0.0.8-linux6-x86_64.tar.gz
			tar xzf libspotify-0.0.8-linux6-x86_64.tar.gz
			cd $HOME/libspotify/libspotify-0.0.8-linux6-x86_64
			make install
		else
			echo "Installing 32-bit libspotify"
			wget http://developer.spotify.com/download/libspotify/libspotify-0.0.8-linux6-i686.tar.gz
			tar xzf libspotify-0.0.8-linux6-i686.tar.gz
			cd $HOME/libspotify/libspotify-0.0.8-linux6-i686
			make install
		fi
		cd $HOME
		rm -r -f ~/libspotify
		
		apt-get install python-software-properties pkg-config -y
		add-apt-repository ppa:team-iquik/xbmc-stable
		apt-get update
		apt-get install git-core make g++ gcc gawk pmount libtool nasm yasm automake cmake gperf zip unzip bison libsdl-dev libsdl-image1.2-dev libsdl-gfx1.2-dev libsdl-mixer1.2-dev libfribidi-dev liblzo2-dev libfreetype6-dev libsqlite3-dev libasound-dev python-sqlite libglew-dev libcurl3 libcurl4-gnutls-dev libxrandr-dev libxrender-dev libmad0-dev libogg-dev libvorbisenc2 libsmbclient-dev libmysqlclient-dev libpcre3-dev libdbus-1-dev libhal-dev libhal-storage-dev libjasper-dev libfontconfig-dev libbz2-dev libboost-dev libenca-dev libxt-dev libxmu-dev libpng-dev libjpeg-dev libpulse-dev mesa-utils libcdio-dev libsamplerate-dev libmpeg3-dev libflac-dev libiso9660-dev libass-dev libssl-dev fp-compiler gdc libmpeg2-4-dev libmicrohttpd-dev libmodplug-dev libssh-dev gettext cvs python-dev libyajl-dev libboost-thread-dev libplist-dev python-support ccache libvdpau-dev debhelper libcurl4-openssl-dev x11proto-xinerama-dev libxinerama-dev libfaac-dev libxtst-dev libmms-dev libfaad-dev libwavpack-dev -y -q			
		apt-get build-dep xbmc -y
		mkdir ~/setup
		cd $HOME/setup	
		git clone git://github.com/akezeke/spotyxbmc2.git
		make -C lib/libnfs && sudo make -C lib/libnfs install
		cd $HOME/setup/spotyxbmc2
		cp ~/appkey.h ~/setup/spotyxbmc2 #Copy Spotify appkey
		./bootstrap; ./configure --prefix=/usr --enable-vdpau --disable-pulse --disable-crystalhd
		make -j4
		make -C lib/addons/script.module.pil
		make install prefix=/usr
		start xbmc-live

	else 	if [ $1 = $S2 ]
		then
			stop xbmc-live
			cd $HOME/setup/spotyxbmc2
			make distclean
			git reset --hard
			git clean -xfd
			git pull --rebase
            make -C lib/libnfs && sudo make -C lib/libnfs install
			./bootstrap ; ./configure --prefix=/usr --enable-vdpau --disable-pulse --disable-crystalhd
			make -j4
			make -C lib/addons/script.module.pil
			make install prefix=/usr
			start xbmc-live
		else
		        echo
		        echo "Usage: $0 <upgrade / update>"
		        echo
		        echo "-- upgrade = full setup (setup GIT, build environment, etc)"
		        echo "-- refresh = update existing XBMC GIT COMPILE to latest version"
		        echo
		fi
	fi
fi

