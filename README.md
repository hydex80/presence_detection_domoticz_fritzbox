#presence_detection.sh

Presence detection domoticz for fritzbox routers

script Presence detection for domoticz  & Frizbox v1.01
created by g.j fun - 19 jan 2019
making use of  fritzconnection  url: https://pypi.org/project/fritzconnection/

dependencies: lxml, jq and requests

tested with: Fritzbox 7581  should work with all routers who supporting TR-064 protocol.
place fritzconnection.py and fritzhosts.py in same directory as this script. 
dont forget to change parameters router inside fritzconnection.py and activate TR-064 on router. 
standard debug information is on just set debug to  false to disable it. 

Since i was not happy with the available presence detection scripts which are worked not very well with iPhone. I made a presence detection script using the TR-064 protocol of my Fritzbox router and get direct information of the router itself.
This saves battery of your smartphone because there is no need of pinging all the time and its more accurate, because the router is made for having the correct information about network devices.

This script is tested with a fritzbox 7581 router but should be working with more routers who has a tr064 protocol implementation. 

What the script does is making use of the python script "fritzconnection" Thnx a lot to Author: Klaus Bremer
sending a request to the router, Get all the available WLAN devices and its state. It worked very fast and reliable. When I set my iPhone in airplane mode after 2 seconds I get the good status. When my iPhone gets in screensaver modus it stays online (which is fine:) 
Since I don't want to send to many requests to domoticz I compare the current state of domoticz with the state of de router. Are they similar? Then I do nothing. Are they different I update the switch state in domoticz

Would be nice to have some feedback, maybe you can test this script on your own fritzbox. Maybe its also working on other routers wich are using the TR-064 protocol standard. feel free to let me know if it works

Installation instructions:

Make sure to give your devices a static ip in your router, we use this ip to target the devices in the script. 

1. First install fritzconnection see for more information: https://pypi.org/project/fritzconnection/
It was a really pain in the @$# to install fritzconnection by using PIP takes ages so feel free to make use of the attachments in this post they are the compiled versions for Raspberry pi Jessie. 

2. install dependencies 
JQ > sudo apt-get install jq
Python > sudo apt-get install python3.6
LXML > sudo apt-get install python-lxml
REQUEST > apt-get install python-requests

2. Place the presence detection script below inside same directory as fritzconnection.py and fritzhosts.py 

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

6. edit the scripts presence detection.sh and change all the settings including the IDX and host ip domoticz and your router.
after that is should be working.
