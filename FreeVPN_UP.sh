#!/bin/bash
#Up FeeVPN VPNBOOK connection
#ensure security

#mumble mumble
CERTDIR=""
CONFIGDIR="${HOME}/.config/freevpns.conf"
LN="================================"
DNS1="nameserver 209.222.18.222"
DNS2="nameserver 209.222.18.218"

VPN=""
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) #directory of the script

#-----WHER RUNNING THE ROOT PART THIS CODE IS NEEDED
if [ ! -z "$2" ]; then
	CONFIGDIR=$2
fi

if [ ! -z "$3" ]; then
	CERTDIR=$3
fi

if [ ! -z "$4" ]; then
	VPN="$4"
fi
#-----

read_config(){
	if [ ! -f $CONFIGDIR ]; then
		echo "No config file. Create now in ${CONFIGDIR} [y/N]?"
		read -r resp
		case $resp in
			y)
				touch ${CONFIGDIR}
				echo "Input path for certificates directory."
				read -r CERTDIR
				echo "CERTDIR=${CERTDIR}" >> $CONFIGDIR
				echo "Done! Config file created in ${CONFIGDIR}."
				read -r -p "Want to set custom DNS servers or use default ones? [y/N]?" respdns

				#=============READ DNS servers
				case $respdns in
					y)
						read -r -p "DNS1" DNS1
						read -r -p "DNS2" DNS2
						echo "DNS1=${DNS1}" >> $CONFIGDIR
						echo "DNS2=${DNS2}" >> $CONFIGDIR
						;;
					*)
						echo "Using defaults."
						;;
				esac
				#============================

				;;
			*)
				echo "No config file. Terminating"
				exit 1
				;;
		esac
	fi

	while read -r line
	do
		#mumble
		cname=$(echo $line | grep -o -E "^[A-Za-z0-9]{1,}")
		cval=$(echo $line | grep -o -E "[^=]{1,}$")
		case $cname in
			CERTDIR)
				if [ -n "$cval" ]; then
					CERTDIR=${cval}
				fi
				;;
			CONFIGDIR)
				if [ -n "$cval" ]; then
					CONFIGDIR=${cval}
				fi
				;;
			DNS1)
				if [ -n "$cval" ]; then
					DNS1=${cval}
				fi
				;;
			DNS2)
				if [ -n "$cval" ]; then
					DNS2=${cval}
				fi
				;;
		esac

	done < "$CONFIGDIR"
}

check_root(){
	if [ "$(whoami)" != "root" ]; then
		echo "Not root."
		echo "Exiting..."
		exit 1
	fi
}

set_DNS(){
	echo $LN
	echo "Setting DNS servers..."
	echo $DNS1 > /etc/resolv.conf #Rewrite here
	echo $DNS2 >> /etc/resolv.conf
	echo "New DNS\`s are:"
	cat /etc/resolv.conf
	echo $LN
}

get_pass(){
	echo "Starting VPN"
	echo "LOGIN=vpnbook"
	echo "PASS:"
	PASS=""
	echo "Wait..."
	wget http://www.vpnbook.com/freevpn -q -O /tmp/vpnbook
	echo "================================"
	PASS=`cat /tmp/vpnbook | grep Password`
	PASS=$(echo $PASS | sed "s/ //g")
	PASS=$(echo $PASS | sed -e "s/<li>Password:<strong>//g" -e "s/<\/strong><\/li>//g")
	echo
	echo $PASS
	echo
	echo "================================"
}

choose_vpn(){
	while [ -z "$CERTDIR" ]; do
		echo "Certificats directory path is not set"
		echo "Input certificate directory"
		read CERTDIR
		echo "CERTDIR=${CERTDIR}" >> "$CONFIGDIR"
	done

	echo "Choose VPN server. Input number"
	echo $LN
	OLDIFS=$IFS
	IFS=$(echo -ne "\n\b")
	cd $CERTDIR
	i=0
	for f in *
	do
		echo ${i}") "${f}
		fileArray[$i]=${i}") "${f}
		(( i++ ))
	done
	IFS=$OLDIFS
	echo $LN

	read NUM
	VPN=$(echo ${fileArray[$NUM]} | grep -o -E "[^ ]{1,}$")


}

run_openvpn(){
	echo ${CERTDIR}"/"${VPN}
	/usr/sbin/openvpn ${CERTDIR}"/"${VPN}
}

if [ ! -z "$1" ]; then
	$1
else
read_config
get_pass
choose_vpn

echo "Root permissions needed to run the rest of the script"
cd $DIR
SCRIPTNAME=$(basename $0)
sudo bash $DIR"/"$SCRIPTNAME check_root $CONFIGDIR
sudo bash $DIR"/"$SCRIPTNAME set_DNS $CONFIGDIR
sudo bash $DIR"/"$SCRIPTNAME run_openvpn $CONFIGDIR $CERTDIR $VPN
fi
