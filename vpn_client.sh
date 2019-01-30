#!/bin/bash
if [ $# != 1 ] ; then
	echo "Usage: (sudo) sh $0 {init|start|stop}" 
	exit 1;
fi

VPN_SERVER_IPV4=""
VPN_PSK=""
VPN_USERNAME=""
VPN_PASSWORD=""

function getIP(){
	ip addr show $1 | grep "inet " | awk '{print $2}' | sed 's:/.*::'       
}

function getGateWay(){
	route -n | grep -m 1 "^0\.0\.0\.0" | awk '{print $2}'
}

function getVPNGateWay(){
	route -n | grep -m 1 "$VPN_SERVER_IPV4" | awk '{print $2}'
}

GW_ADDR=$(getGateWay)

function init() {
	docker run --rm -it --privileged --net=host -v /lib/modules:/lib/modules:ro -e VPN_SERVER_IPV4=$VPN_SERVER_IPV4 -e VPN_PSK=$VPN_PSK -e VPN_USERNAME=$VPN_USERNAME -e VPN_PASSWORD=$VPN_PASSWORD simpleapples/l2tp-ipsec-vpn-client
}

function start() {
	route add $VPN_SERVER_IPV4 gw $GW_ADDR $IFACE
	route add default gw $(getIP ppp0)
	route delete default gw $GW_ADDR
}

function stop() {
	VPN_GW=$(getVPNGateWay)
	route delete $VPN_SERVER_IPV4 gw $VPN_GW $IFACE
	route add default gw $VPN_GW
}

$1
exit 0