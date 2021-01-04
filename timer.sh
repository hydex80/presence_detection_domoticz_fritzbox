#Script to test how long the fritzbox needs to put off given device. 
#change variables Ip = fritzbox ip and mac_adress = mac adres device you want to test
ip_fritzbox=192.168.178.1
mac_address=CC:1C:75:41:2C:62
# end changing variables

SECONDS=0

echo "Starting test to see how long it takes to switch device to off in the fritzbox" 
echo "Make sure device is on the wifi network" 
read -n 1 -r -s -p $'Switch device now to off wifi network and Press [Enter] to continue...\n'
now=$(date)
echo "excuting script on $now this can take to over 10 minutes (Press Ctrl C to cancel script)"

while true
do
        echo -ne '.'
        test=$(sudo python fritzhosts.py -i $ip_fritzbox -p test -d $mac_address -q)        
        if [ $test == "0" ]; then
                break
        fi
        
        echo -ne '.'

done
duration=$SECONDS
end=$(date)
echo ""
echo "Test completed on $end"
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
