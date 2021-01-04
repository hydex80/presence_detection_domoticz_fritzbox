# Script to test how long the fritzbox needs to put off given device. 
#Put after -i ip of fritzbox and after -d mac address of your device
test=$(sudo python fritzhosts.py -i 192.168.178.1 -p test -d CC:1C:75:41:2C:62 -q)

SECONDS=0

echo "Starting test to see how long it takes to switch device to off in the fritzbox" 
echo "Make sure device is on the wifi network" 
read -n 1 -r -s -p $'Switch device now to off wifi network and Press [Enter] to continue...\n'
now=$(date)
echo "excuting script on $now this can take to over 10 minutes (Press Ctrl C to cancel script)"

while true
do
        echo -ne '.'
        
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
