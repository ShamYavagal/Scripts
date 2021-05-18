#!/bin/bash

usage() {
    name = $(basename $0)
    echo "Usage : $Script Interface_Name"

}

IFACE=$1

if [[ "$#" -eq "1" ]]; then

    while true; 
        do
            RECV1=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
            XMIT1=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)
            sleep 1
            RECV2=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
            XMIT2=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)

            XMIT_Bps=$(expr $XMIT2 - $XMIT1)
            RECV_Bps=$(expr $RECV2 - $RECV1)

            XMIT_kBps=$(expr $XMIT_Bps / 1000)
            RECV_kBps=$(expr $RECV_Bps / 1000)
            
            XMIT_mBps=$(expr $XMIT_kBps / 1000)
            RECV_mBps=$(expr $RECV_kBps / 1000)

            XMIT_mbps=$(expr $XMIT_mBps \* 8)
            RECV_mbps=$(expr $RECV_mBps \* 8)


            echo "Transmit $1: $XMIT_mbps mb/s Receive $1: $RECV_mbps mb/s"
        done
else
    echo "Incorrect Interface Name"
    echo "Please Run 'ifconfig' Or 'ip addr show' To Find The Correct Interface Name"

fi
