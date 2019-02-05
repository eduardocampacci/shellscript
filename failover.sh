#!/bin/bash

# Tempo de verificação em segundos
SLEEPTIME=10

# Endereço de testes
TESTIP=200.147.67.142

# Tempo limite do ping em segundos
TIMEOUT=2

# Interfaces externas WAN.
EXTIF1=enp0s8     #VIVO
EXTIF2=enp0s3     #GVT

# Endereços das interfaces externas.
# IPs
IP1=10.0.3.15        #VIVO
IP2=192.168.1.17     #GVT

# Gateway das interfaces externas
GW1=10.0.3.2          #VIVO
GW2=192.168.1.254     #GVT

# Relative weights of routes. Keep this to a low integer value. I am using 4
# for TATA connection because it is 4 times faster
W1=3
W2=2

# Nome dos provedores dos links, use o mesmo nome das tabelas
NAME1=link1     #GVT
NAME2=link2     #VIVO

#No of repeats of success or failure before changing status of connection
SUCCESSREPEATCOUNT=2
FAILUREREPEATCOUNT=5

# Do not change anything below this line

# Last link status indicates the macro status of the link we determined. This is down initially to force routing change upfront. Don't change these values.
LLS1=1
LLS2=1

# Last ping status. Don't change these values.
LPS1=1
LPS2=1

# Current ping status. Don't change these values.
CPS1=1
CPS2=1

# Change link status indicates that the link needs to be changed. Don't change these values.
CLS1=1
CLS2=1

# Count of repeated up status or down status. Don't change these values.
COUNT1=0
COUNT2=0

while : ; do
        ping -W $TIMEOUT -I $IP1 -c 1 $TESTIP > /dev/null  2>&1
        RETVAL=$?

        if [ $RETVAL -ne 0 ]; then
		echo $NAME1 Down
		CPS1=1
        else
		CPS1=0
        fi

	if [ $LPS1 -ne $CPS1 ]; then
		echo Ping status changed for $NAME1 from $LPS1 to $CPS1
		COUNT1=1
	else
		if [ $LPS1 -ne $LLS1 ]; then
			COUNT1=`expr $COUNT1 + 1`
		fi
	fi

        if [[ $COUNT1 -ge $SUCCESSREPEATCOUNT || ($LLS1 -eq 0 && $COUNT1 -ge $FAILUREREPEATCOUNT) ]]; then
		echo Uptime status will be changed for $NAME1 from $LLS1
		CLS1=0
		COUNT1=0
		if [ $LLS1 -eq 1 ]; then
			LLS1=0
		else
			LLS1=1
		fi
	else 
		CLS1=1
        fi

	LPS1=$CPS1

	ping -W $TIMEOUT -I $IP2 -c 1 $TESTIP > /dev/null  2>&1
       	RETVAL=$?

	if [ $RETVAL -ne 0 ]; then
		echo $NAME2 Down
                CPS2=1
        else
                CPS2=0
        fi

        if [ $LPS2 -ne $CPS2 ]; then
		echo Ping status changed for $NAME2 from $LPS2 to $CPS2
                COUNT2=1
        else
                if [ $LPS2 -ne $LLS2 ]; then
                        COUNT2=`expr $COUNT2 + 1`
                fi
        fi

        if [[ $COUNT2 -ge $SUCCESSREPEATCOUNT || ($LLS2 -eq 0 && $COUNT2 -ge $FAILUREREPEATCOUNT) ]]; then
		echo Uptime status will be changed for $NAME2 from $LLS2
		CLS2=0
		COUNT2=0
                if [ $LLS2 -eq 1 ]; then
                        LLS2=0
                else
                        LLS2=1
                fi
	else
		CLS2=1
        fi

	LPS2=$CPS2

	if [[ $CLS1 -eq 0 || $CLS2 -eq 0 ]]; then
		if [[ $LLS1 -eq 1 && $LLS2 -eq 0 ]]; then 
			echo Switching to $NAME2
                        ip route replace default scope global via $GW2 dev $EXTIF2

                        ip rule del fwmark 0x10 lookup link1 prio 3
                        ip rule del fwmark 0x20 lookup link2 prio 3

                        ip route flush cache


		elif [[ $LLS1 -eq 0 && $LLS2 -eq 1 ]]; then
			echo Switching to $NAME1
                        ip route replace default scope global via $GW1 dev $EXTIF1

                        ip rule del fwmark 0x10 lookup link1 prio 3
                        ip rule del fwmark 0x20 lookup link2 prio 3

                        ip route flush cache


		elif [[ $LLS1 -eq 0 && $LLS2 -eq 0 ]]; then
			echo Restoring default load balancing
                 
                        ip rule add fwmark 0x10 lookup link1 prio 3
                        ip rule add fwmark 0x20 lookup link2 prio 3

                        ip route flush cache

                        ip route replace default scope global nexthop via $GW1 dev $EXTIF1 weight $W1 nexthop via $GW2 dev $EXTIF2 weight $W2
		fi
	fi
        sleep $SLEEPTIME
done

