#!/bin/bash

#presence detection 2.3 Fritzbox by G.J Funcke
#License: MIT https://opensource.org/licenses/MIT
#Author: G.J. Funcke 
#thnx to allesvanzelf for adding lighting protection 
#Source: https://github.com/hydex80/presence_detection_domoticz_fritzbox

#Making use: of fritzconnection 
#License: MIT https://opensource.org/licenses/MIT
#Author: Klaus Bremer

#all variables are stored inside config.txt 
#Run  presence_detection.sh install to start a new  installation
#Run  presence_detection.sh debug to enable debugging
#run  presence_detection.sh to just start the main functionality 

#default variables
run_install=0
show_debug=0

#current directory script
cwd=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

#some styling ;-)
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


if [ "$1" = "debug" ]; then
echo "debug enabled" 
show_debug=1 
clear;
echo "------------------------------------------------------------"
echo "Presence detection for Domoticz using Fritzbox version 2.3"
echo "------------------------------------------------------------"
echo 


fi
#check if config file exist.
if [ ! -f $cwd/config.txt ] || [ "$1" = "install" ]; then
run_install=1
else

# Load data.
source $cwd/config.txt

#check if all variables are set 
if [[ -z $ip_fritzbox || -z $pass_fritzbox || -z $ip_domoticz || -z $device_names || -z $device_macs || -z $device_idx  ]]; then
echo "The config file is corrupt!"
config_file=1;
read -p "Do you want to run presence_detection.sh install  Y/n " -n 1 -r
                echo    
 		
		#install dependencies
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo bash presence_detection.sh install 
                fi
exit 1
fi

i=0 
  
# Loop upto size of array 
# st 
while [ $i -lt ${#device_names[@]} ] 
do

	echo "checking:${device_names[i]}"
	
	status_domoticz_device=$(curl -s 'http://'$ip_domoticz'/json.htm?type=devices&rid='${device_idx[i]} | jq -r [.result][][].Data)   
	status_fritzbox_device=$(python $cwd/fritzhosts.py -i $ip_fritzbox -p $pass_fritzbox -d ${device_macs[i]})

	sleep 2; 
	output_router_device=$(grep "NewActive              : 1" <<<"$status_fritzbox_device")  
	if [ -n "$ip_repeater" ]; then
		status_repeater_device=$(python $cwd/fritzhosts.py -i $ip_repeater -p $pass_fritzbox -d ${device_macs[i]})
		sleep 2;
		output_repeater_device=$(grep "NewActive              : 1" <<<"$status_repeater_device")  

 		if [ -z "$output_router_device" ] && [ -z "$output_repeater_device" ]; then
        		# device is not active in router and not active in repeater  so set it to off
        		status_router_device="Off" 
        	else
        		#device is active so we set variable to on
        
       			 status_router_device="On"
 		fi

	#else if there is no repeater 
	else
        	if [ -z "$output_router_device" ];then
        		# device is not active in router and not active in repeater  so set it to off
        		status_router_device="Off" 
        	else
        		#device is active so we set variable to on
           
        		status_router_device="On"
        	fi
	fi

	if [ "$status_router_device" == "$status_domoticz_device" ]; then
		# both are simular so there is nothing to change. 
		echo $(date -u) "status router and domoticz for ${device_names[i]} are simular, we do nothing"  
	else
		#router status vs domoticz status are not equal we set domoticz status to router status. 
		#we change the value in domoticz
		echo -e  $(date -u)"status router is not simular to status domoticz. ${GREEN} We change status domoticz for ${device_names[i]} to  $status_router_device${NC}"

##Added '&passcode=$domoticzpasscode' by Allesvanzelf
		wget -q --delete-after "http://$ip_domoticz/json.htm?type=command&param=switchlight&idx=${device_idx[i]}&switchcmd=$status_router_device&passcode=$domoticzpasscode" >/dev/null 2>&1

		#we send logging information to domoticz
		wget -q --delete-after "http://$ip_domoticz/json.htm?type=command&param=addlogmessage&message=presence-detection-logging ${device_names[i]} = $status_router_device" >/dev/null 2>&1
 	fi

#debug information:

	if [ "$show_debug" = 1 ]; then
	echo "debug information:" 
	echo "status domoticz:"
	echo "$status_domoticz_device"
	echo "-----------------------"
	echo "status fritzbox:"
	echo "$status_fritzbox_device"
	echo "-----------------------"
	echo "status repeater:"
	echo "$status_repeater_device"
	echo "-----------------------"
	fi


	i=`expr $i + 1` 
done
fi

if [ "$show_debug" = 1 ]; then
echo "dependencies installed:" 
echo "installed python version:" 
python --version
echo "installed JQ  version:" 
jq --version
echo "---------------------"
echo
echo "config file variables:"    
echo "---------------------"
cat $cwd/config.txt
echo "---------------------"
fi

# install script
if [ "$run_install" = 1 ]; then

	# This is a user friendly installer for presence detection fritzbox 2.3

	#variables
	i="1"
	device_name=()
	device_mac=()
	device_idx=()
	echo "--------------------------------------------------------"
	echo " Installer for fritzbox presence detection 2.3" 
	echo "--------------------------------------------------------"
	#check if config file exist.
	if [ -f  $cwd/config.txt ]; then

	read -p "We found an existing config file, this file will be overwritten are you sure? Y/n " -n 1 -r
                echo    

        #
                if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo rm -f $cwd/config.txt 
	 echo "continue install script"       
	else
	echo "installation aborted" 
	exit 1
	fi
	fi

check_jq=$(dpkg-query -W -f='${Status} ${Version}\n' jq)
check_python=$(dpkg-query -W -f='${Status} ${Version}\n' python)
check_lxml=$(dpkg-query -W -f='${Status} ${Version}\n' python-lxml)
check_requests=$(dpkg-query -W -f='${Status} ${Version}\n' python-requests)


if [[ $check_jq == *"installed"* ]]; then
echo -e "JQ:${GREEN}[OK]${NC}" 

else
echo -e "JQ:${RED}[not installed!]${NC}"
check_dep=0
fi

if [[ $check_python == *"installed"* ]]; then
echo -e "Python:${GREEN}[OK]${NC}" 

else
echo -e "Python:${RED}[not installed!]${NC}"
check_dep=0
fi


if [[ $check_lxml == *"installed"* ]]; then
echo -e "Python-lxml :${GREEN}[OK]${NC}" 

else
echo -e "Python-lxml:${RED}[not installed!]${NC}"
check_dep=0
fi

if [[ $check_requests == *"installed"* ]]; then
echo -e "Python-requests:${GREEN}[OK]${NC}" 

else
echo -e "Python-requests:${RED}[not installed!]${NC}"
check_dep=0
fi

	if [ "$check_dep" = 0 ]; then

	   read -p "There are missing dependencies! Do you want to install dependencies Y/n " -n 1 -r
        	echo    

        #install dependencies
        	if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo apt-get install python jq python-lxml python-requests
        	
		else
		echo "one or more dependencies are not installed, installation of this script cannot continue. Run: sudo apt-get install python jq python-lxml python-requests"
                echo "and reinstall the script with: sudo bash  presence_detection.sh install"
		exit 1
		fi 
fi


	#questions for config file 
	echo  
	echo -n "Enter ip adres of fritzbox and press [ENTER]: "
	read ip_fritzbox 
	echo "ip_fritzbox=$ip_fritzbox" >> config.txt
	echo -n "Enter password of fritzbox (web interface password) and press [ENTER]: "
	read pass_fritzbox
	echo "pass_fritzbox=$pass_fritzbox" >> config.txt
	echo -n "Enter ip adres of fritz repeater (leave blank if you dont have any)  and press [ENTER]: "
	read ip_repeater
	echo "ip_repeater=$ip_repeater" >> config.txt
	echo -n "Enter ip adres of domoticz including port default: 127.0.0.1:8080 and press [ENTER]: "
	read ip_domoticz 
	echo "ip_domoticz=$ip_domoticz" >> config.txt
	## added by Allesvanzelf	
	echo -n "Enter the Light/Switch protection passcode if you any in domoticz, if you don't have any leave blank and press[ENTER]: "
	read domoticzpasscode
	echo "domoticzpasscode=$domoticzpasscode" >> config.txt


	#check status domoticz
	status_domoticz=$(curl -s  'http://'$ip_domoticz'/json.htm?type=command&param=getversion' | jq -r .status)

	if [ -z $status_domoticz ]; then

	echo  "there is a problem retrieving information of  domoticz, Restart install script and  check domoticz ip settings or check if domoticz is offline"
	exit 1 

	else
	echo -e "Status domoticz ${GREEN}[OK]${NC}"
	fi

	read -p "Do you want to make virtual hardware and virtual sensors automatically in Domoticz   Y/n " -n 1 -r
	echo    
                
                         
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                        create_auto=1

                        idx_virtual_hardware=$(curl -s  'http://'$ip_domoticz'/json.htm?type=command&param=addhardware&htype=15&name=presence_detection&enabled=true&datatimeout=0' | jq -r .idx )
                        
                        if [ -z $idx_virtual_hardware ]; then

                        echo  "there is a problem adding the virtual hardware to domoticz. $idx_virtual_hardware"
                        exit 1

                        else
                        echo -e "Virtual hardware Presence_detection (IDX: $idx_virtual_hardware) added to domoticz ${GREEN}[OK]${NC}"
                        fi

		fi




	echo -n "Enter number of devices you want to add  and press [ENTER]: "
	read number_of_devices

	number_of_devices=$((number_of_devices+1))
	while [ $i -lt $number_of_devices ]
	do

		echo -n "Enter name of device$i use underscore instead of spaces and press [ENTER]:" 
		read names

		#remove spaces  in name of device
		dev_name=${names// /_}

		#add values to array device_name
		device_name+=("$dev_name")

		echo -n "Enter mac adress of device$i for example: 20:5E:A8:C1:AE:C0 and press [ENTER]:" 
		read -a mac
		device_mac+=("$mac")
 
	if [ "$create_auto" -eq "1" ];then

			add_virtual_device=$(curl -s  'http://'$ip_domoticz'/json.htm?type=createdevice&idx='$idx_virtual_hardware'&sensorname='$dev_name'&sensormappedtype=0xF449')
                        status_virtual_device=$(jq -r .status  <<< "$add_virtual_device") 
                        idx_virtual_device=$(jq -r .idx  <<< "$add_virtual_device") 

                        if [ -z $status_virtual_device ]; then

                        echo  "there is a problem adding the virtual device to domoticz. $add_virtual_device"
                        exit 1

                        else
                        echo -e "Virtual device $dev_name (IDX: $idx_virtual_device) added to domoticz ${GREEN}[OK]${NC}"
                        fi
		device_idx+=("$idx_virtual_device")
	else 
		echo -n "Enter IDX  of device $i and press  [ENTER]:" 
		read -a idx      
		device_idx+=("$idx")

	fi

	i=$[$i+1] 
	done


	# save device_name  values inside configfile
	for dn in "${device_name[*]}"
	do      
		 echo "device_names=($dn)" 
	done>>config.txt

	# save device_mac values inside configfile
	for dn in "${device_mac[*]}"
	do
      		 echo "device_macs=($dn)" 
	done >>config.txt

	# save device_idx values inside configfile
	for dn in "${device_idx[*]}"
	do
		 echo "device_idx=($dn)" 
	done >>config.txt

	# run presence detection straight away
	read -p "Do you want to run  presence detection  Y/n " -n 1 -r

	if [[ $REPLY =~ ^[Yy]$ ]]; then
    	sudo bash presence_detection.sh
	fi
echo
echo "Installation is complete"
echo "You have to add the script to your crontab so it will check every minute if devices are on your network." 
echo "you can do this to  add this line :  * * * * * $cwd/presence_detection.sh  to your crontab. "
echo "all the settings are written inside the config.txt file. If you want to change anything you can also change the settings inside this file." 
echo "Good luck, if you are happy or if you have any comments please goto the domoticz forum. or send (me) funky a PM "
fi

