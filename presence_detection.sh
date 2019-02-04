#!/bin/bash

#presence_detection.sh

#script Presence detection for domoticz  & Fritzbox v1.04
#created by g.j funcke - 4 feb 2019
#making use of  fritzconnection  url: https://pypi.org/project/fritzconnection/
#dependencies: lxml, jq and requests
#tested with: Fritzbox 7581 and Fritzbox Repeater 1750E should work with all routers who supporting TR-064 protocol.
#place fritzconnection.py and fritzhosts.py in same directory as this script. 
#dont forget to change parameters router inside fritzconnection.py and activate TR-064 on router. 
#standard debug information is on just set debug to  false to disable it. 
# if you have a repeater please specify ip below. 


#setup device(s) change values here Mac adresses can be found in your router > home network > network > devices pencil > device information
mac_device1=AC:1F:74:41:2A:62
name_device1="Iphone GJ"
mac_device2=20:EE:28:C1:EF:B0
name_device2="Iphone Pat"
idxdevice1=424
idxdevice2=428

#setup  router (http://fritz.box), repeater (Fritzbox repeater http://fritz.repeater) and  domoticz change values
password_fritzbox=yourpassword
host_fritzbox=192.168.178.1
#setup repeater, if you dont have any leave blank 
host_repeater=
#setup host domoticz
host_domoticz=192.168.178.33:8080

#set debug to true or false to see logging information, leave on when using for the first time.. you see some checks. Leave of after it works 
enable_debug=true

#some styling ;-)
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

#current directory script
cwd=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

#get current status of device(s) in domoticz 

if [ "$enable_debug" == "true" ]; then
clear;
echo "------------------------------------------------------------"
echo "Presence detection for Domoticz using Fritzbox version 1.0.4"
echo "------------------------------------------------------------"
echo -e "\n check availability of fritzbox"
sleep 1;
if ping -c 1 $host_fritzbox &> /dev/null
then
  echo -e "${GREEN} Fritzbox is available${NC} gives answer on ip $host_fritzbox \n"
else
  echo -e "${RED} Error!!!! fritzbox is not available, check ip adress of variable  host_fritzbox"
exit 1
fi

if [ -n "$host_repeater" ]; then
echo "check availability of repeater"

if ping -c 1 $host_repeater &> /dev/null
then
  echo -e  "${GREEN} Repeater is available${NC} gives answer on ip $host_repeater \n" 
else
  echo -e  "${RED} Error!!!! Repeater is not available, check ip adress of host_repeater or leave empty is you dont have one${NC} "
exit 1
fi
fi

#Get status domoticz
status_domoticz_device1=$(curl 'http://'$host_domoticz'/json.htm?type=devices&rid='$idxdevice1 | jq -r [.result][][].Data)
status_domoticz_device2=$(curl 'http://'$host_domoticz'/json.htm?type=devices&rid='$idxdevice2 | jq -r [.result][][].Data)
else
status_domoticz_device1=$(curl -s 'http://'$host_domoticz'/json.htm?type=devices&rid='$idxdevice1 | jq -r [.result][][].Data)
status_domoticz_device2=$(curl -s 'http://'$host_domoticz'/json.htm?type=devices&rid='$idxdevice2 | jq -r [.result][][].Data)
fi

#get device status of devices in Router
echo "getting output router.. plz wait... " ;
output_device1=$(python $cwd/fritzhosts.py -i $host_fritzbox -p $password_fritzbox -d $mac_device1)
sleep 2; 
output_device2=$(python $cwd/fritzhosts.py -i $host_fritzbox -p $password_fritzbox -d $mac_device2);
sleep 2;
status_router_device1=$(grep "NewActive              : 1" <<<"$output_device1")  
status_router_device2=$(grep "NewActive              : 1" <<<"$output_device2")  


#get device status of repeater 
if [ -n "$host_repeater" ]; then
echo "getting output repeater..plz wait..." ;

output_extender_device1=$(python $cwd/fritzhosts.py -i $host_repeater -p $password_fritzbox -d $mac_device1)
sleep 2;
output_extender_device2=$(python $cwd/fritzhosts.py -i $host_repeater -p $password_fritzbox -d $mac_device2)
sleep 2;
status_extender_device1=$(grep "NewActive              : 1" <<<"$output_extender_device1") 
status_extender_device2=$(grep "NewActive              : 1" <<<"$output_extender_device2")  


	if [ -z "$status_router_device1" ] && [ -z "$status_extender_device1" ]; then
	# device is not active in router and not active in repeater  so set it to off
	status_router_device1="Off" 
	else
	#device is active so we set variable to on
	
	status_router_device1="On"
	fi

	if [ -z "$status_router_device2" ] && [ -z "$status_extender_device2" ]; then
	# device is not active in router and not active in repeater  so set it to off
	status_router_device2="Off" 
	else
	#device is active so we set variable to on
	
	status_router_device2="On"
	fi

#else if there is no repeater 
else
 	if [ -z "$status_router_device1" ];then
        # device is not active in router and not active in repeater  so set it to off
        status_router_device1="Off" 
        else
        #device is active so we set variable to on
           
        status_router_device1="On"
        fi

	if [ -z "$status_router_device2" ];then
        # device is not active in router and not active in repeater  so set it to off
        status_router_device2="Off" 
        else
        #device is active so we set variable to on
           
        status_router_device2="On"
        fi	
fi



if [ "$enable_debug" == "true" ]; then
echo "output router $name_device1 = $output_device1"
echo "output router $name_device2 = $output_device2"
echo "-----------------------------------------------------"
 if [ -n  "$host_repeater" ];  then 
 echo "output repeater $name_device1 = $output_extender_device1"
 echo "output repeater $name_device2 = $output_extender_device2"  
 echo "-----------------------------------------------------"
 echo "status repeater $name_device1 = $status_extender_device1"
 echo "status repeater $name_device2 = $status_extender_device2"
fi
echo "status router $name_device1 = $status_router_device1"
echo "status router $name_device2 = $status_router_device2"
echo "status in domoticz $name_device1 = $status_domoticz_device1"  
echo "status in domoticz $name_device2 = $status_domoticz_device2"
fi




#now we compare the status of the router vs the status of domoticz 

if [ "$status_router_device1" == "$status_domoticz_device1" ]; then
# both are simular so there is nothing to change. 
echo $(date -u) "status router and domoticz for $name_device1 are simular, we do nothing"  
else
#router status vs domoticz status are not equal we set domoticz status to router status. 
#we change the value in domoticz
echo -e  $(date -u)"status router is not simular to status domoticz. ${GREEN} We change status domoticz for $name_device1 to  $status_router_device1 ${NC}" 
wget -q --delete-after "http://$host_domoticz/json.htm?type=command&param=switchlight&idx=$idxdevice1&switchcmd=$status_router_device1" >/dev/null 2>&1

#we send logging information to domoticz
wget -q --delete-after "http://$host_domoticz/json.htm?type=command&param=addlogmessage&message=presence-detection-logging $name_device1 = $status_router_device1" >/dev/null 2>&1
 
fi


if [ "$status_router_device2" == "$status_domoticz_device2" ]; then
# both are simular so there is nothing to change.
echo $(date -u) "status router and domoticz for $name_device2 are simular, we do nothing" 
else
#router status vs domoticz status are not equal we set domoticz status to router status. 
echo $(date -u) "status router is not simular to status domoticz. ${GREEN} We change status domoticz for $name_device2 to  $status_router_device2 ${NC}" 
#we change the value in domoticz
wget -q --delete-after "http://$host_domoticz/json.htm?type=command&param=switchlight&idx=$idxdevice2&switchcmd=$status_router_device2" >/dev/null 2>&1

#we send logging information to domoticz
wget -q --delete-after "http://$host_domoticz/json.htm?type=command&param=addlogmessage&message=presence-detection-logging $name_device2 = $status_router_device2" >/dev/null 2>&1
 
fi

