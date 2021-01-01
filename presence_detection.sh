#!/bin/bash

#presence detection 2.5 Fritzbox by G.J Funcke
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
# delaytime is in seconds. Its the time between the checks for new fritzdevices. 
delaytime=0 

#working variables do not change
devices_output=(Device MAC_address Fritzbox_status Domoticz_status New_status)
output_router_device=()

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
echo "Presence detection for Domoticz using Fritzbox version 2.5"
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
	if [[ -z $ip_fritzbox || -z $ip_domoticz || -z $device_names || -z $device_macs || -z $device_idx  ]]; then
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

# load all data from fritzbox inside status_fritzbox so we can loop trough 
echo "reading devices from fritzbox on $ip_fritzbox"
status_fritzbox_device=$(python $cwd/fritzhosts.py -i $ip_fritzbox -p $pass_fritzbox)
while [ $i -lt ${#device_names[@]} ] 
do
	#Load data for later output
	devices_output+=(${device_names[i]})
	devices_output+=(${device_macs[i]})


	echo "checking device:${device_names[i]}"
	
	x=0
	status_device=0
		
	#remove all spaces from values fritzboxconnection 
	status_fritzbox_device=$(echo $status_fritzbox_device | tr -d ' ')
	status_device_mac="${device_macs[i]}active"

		if [[ "$status_fritzbox_device" == *"$status_device_mac"* ]]; then
		status_device=1
		devices_output+=(Active)
		else
		devices_output+=(-)
		fi

	#loading status from domoticz
	status_domoticz_device=$(curl -s 'http://'$ip_domoticz'/json.htm?type=devices&rid='${device_idx[i]} | jq -r [.result][][].Data)   
	devices_output+=($status_domoticz_device)


	if [ "$status_device" = 1 ];then 
    #device is active so we set variable to on
    status_router_device="On"
    else
    #device is  not active so we set variable to off
    status_router_device="Off"
    fi

	if [ "$status_router_device" == "$status_domoticz_device" ]; then
		# both are simular so there is nothing to change. 
		echo $(date -u) "status router and domoticz for ${device_names[i]} are simular, we do nothing"  
		devices_output+=(-)
	else
		#router status vs domoticz status are not equal we set domoticz status to router status. 
		#we change the value in domoticz
		echo -e  $(date -u)"status router is not simular to status domoticz. ${GREEN} We change status domoticz for ${device_names[i]} to  $status_router_device${NC}"
		devices_output+=($status_router_device)
##Added '&passcode=$domoticzpasscode' by Allesvanzelf
		wget -q --delete-after "http://$ip_domoticz/json.htm?type=command&param=switchlight&idx=${device_idx[i]}&switchcmd=$status_router_device&passcode=$domoticzpasscode" >/dev/null 2>&1

		#we send logging information to domoticz
		wget -q --delete-after "http://$ip_domoticz/json.htm?type=command&param=addlogmessage&message=presence-detection-logging ${device_names[i]} = $status_router_device" >/dev/null 2>&1
 	fi

#debug information:


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
#print all devices into columns 
echo ""
echo "Overview of status Fritbox vs Domotics"
echo "----------------------------------------------------------------------------------" 
printf '%s %s %s %s %s\n' "${devices_output[@]}" | column -t
echo "----------------------------------------------------------------------------------" 
echo "Note! Depending on how many devices are on the network it can take up to 10 minutes before you see a status change"
echo "Please be patient wait a couple of minutes and try again if you see no changes."
fi

# install script
if [ "$run_install" = 1 ]; then

	# This is a user friendly installer for presence detection fritzbox 2.4

	#variables
	i="1"
	device_name=()
	device_mac=()
	device_idx=()
	echo "--------------------------------------------------------"
	echo " Installer for fritzbox presence detection 2.5" 
	echo "--------------------------------------------------------"
	#check if config file exist.
	if [ -f  $cwd/config.txt ]; then
	echo "Found! config file:"    
	echo "---------------------"
	cat $cwd/config.txt
	echo "---------------------"
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
get_gateway=$(route -n | grep 'UG[ \t]' | awk '{print $2}')

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
	     
	echo -n "Enter password of fritzbox (web interface password) and press [ENTER]: "
	read pass_fritzbox
	echo "pass_fritzbox=$pass_fritzbox" >> config.txt

	echo -e "Found router (possibly fritzbox) on: $get_gateway" 
	echo -n "Enter ip adress  of Fritzbox and press [ENTER]:" 
    read ip_fritzbox
	echo "ip_fritzbox=$ip_fritzbox" >> config.txt

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

	echo -e  ${RED}"There is a problem retrieving information of domoticz, Restart install script and  check domoticz ip settings or check if domoticz is offline ${NC}"
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
				else
				create_auto=0;
				fi

    echo "Searching for devices on your fritzbox, you can copy paste mac adres"
    python $cwd/fritzhosts.py -i $ip_fritzbox -p $pass_fritzbox    
	echo -n "Enter number of devices you want to monitor and press [ENTER]:"
	read number_of_devices
	i=1
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
	read -p "Do you want to run presence detection  Y/n " -n 1 -r

	if [[ $REPLY =~ ^[Yy]$ ]]; then
	printf "\033c"
    	sudo bash presence_detection.sh debug
	fi
	
echo "Setting right permissions for presence_detection.sh"
chmod +x $cwd/presence_detection.sh
echo 
echo "Installation is complete"
echo "Note! Depending on how many devices are on the network it can take up to 10 minutes before you see a status change"
echo "Please be patient wait a couple of minutes and try again if you see no changes."
echo ""
echo "You have to add the script to your crontab so it will check every minute if devices are on your network." 
echo "you can do this to  add this line so it runs every minute :  * * * * * $cwd/presence_detection.sh  to your crontab. "
echo "all the settings are written inside the config.txt file. If you want to change anything you can also change the settings inside this file." 
echo "Don't forget to disable wifi security on your devices on your home network wifi  "
echo "More Questions and answers can be found on: https://github.com/hydex80/presence_detection_domoticz_fritzbox"
echo "Good luck, if you are happy or if you have any comments please goto the domoticz forum. or send (me) funky a PM"
fi

