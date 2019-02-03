#presence_detection.sh

Presence detection domoticz for fritzbox routers

script Presence detection for domoticz  & Frizbox v1.01
created by g.j fun - 19 jan 2019

making use of  fritzconnection  url: https://pypi.org/project/fritzconnection/

dependencies: python lxml, jq and requests

tested with: Fritzbox 7581 should work with all (fritzbox)routers who are supporting TR-064 protocol.
 
Background information:
Since i was not happy with the available presence detection scripts which are worked not very well with iPhone. I made a presence detection script using the TR-064 protocol of my Fritzbox router and get direct information of the router itself.
This saves battery of your smartphone because there is no need of pinging all the time and its more accurate, because the router is made for having the correct information about network devices.

This script is tested with a fritzbox 7581 router but should be working with more routers who has a tr064 protocol implementation. 

What the script does is making use of the python script "fritzconnection" Thnx a lot to Author: Klaus Bremer
sending a request to the router, Get all the available WLAN devices and its state. It is very fast and reliable. When I set my iPhone in airplane mode after 2 seconds I get the good status. When my iPhone gets in screensaver modus it stays Online in Domoticz (which is fine:) 
Since I don't want to send to many requests to domoticz I compare the current state of domoticz with the state of de router. Are they similar? Then I do nothing. Are they different I update the switch state in domoticz

When you have a Fritzbox Repeater. You should also add this to the script. The script will look for your devices on the fritzbox and on the repeater. 
You can find the repeaters Ip adres by going to: http://fritz.repeater use the same password as logging in on your router. You can login to your router to go to http://fritz.box

Would be nice to have some feedback, maybe you can test this script on your own fritzbox. Maybe its also working on other routers wich are using the TR-064 protocol standard. feel free to let me know if it works

Installation instructions:

Make sure to give your devices a static ip in your router http://fritz.box Login, and go to Home network > network and then click on the device you want to use > click on pencil and check: Always assign this network device the same IPv4 address, we use this ip to target the devices in the script. 

1. install dependencies:

sudo apt-get install python jq python-lxml python-requests

and update en upgrade with: 

sudo apt-get update
sudo apt-get upgrade

2.  Download script with:

git clone https://github.com/hydex80/presence_detection_domoticz_fritzbox 

3. edit the fritzconnection.py and change 

fritzconnection defaults: 
FRITZ_IP_ADDRESS = '<put here your router ip like 192.168.178.1>'

4. Activate on your router the TR-064 protocol on fritzbox it is in >home network > network > network settings > Allow access for applications 

(you can test the script by running: python fritzconnection.py -p(put here password of router login (so no wifi password)) for example -pmypassword if you see a version of the router it works! if you see errors it has to do with dependencies witch are missing so install those first to get it working

5. Go to domoticz and make dummy hardware for your smartphones 

settings > hardware > new > dummy give it a name for example smartphones
make 2 virtual sensors by clicking on make virtual sensor
give type: switch and give it a name
after that go to devices
and write down the IDX of the 2 devices

6. edit the scripts presence detection.sh and change all the settings including the IDX and host ip domoticz and your  host router and host repeater (if you have any).
after that it should be working.

Note
This script is made for 2 devices, if you want 1 device of more then 2 devices you just have to change presence_detection.sh and change and code. If you want to make contributions to this script, feel free to do that! 
