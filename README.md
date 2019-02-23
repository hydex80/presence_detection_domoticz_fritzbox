#presence_detection.sh

Presence detection domoticz for fritzbox routers

script Presence detection for domoticz  & Fritzbox v2.0
created by g.j funcke - 23  feb 2019

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

-------------------------
Installation instructions:

Make sure to give your devices a static ip in your router http://fritz.box Login, and go to Home network > network and then click on the device you want to use > click on pencil and check: Always assign this network device the same IPv4 address, we use this ip to target the devices in the script. 

1. Activate on your router the TR-064 protocol on fritzbox it is in >home network > network > network settings > Allow access for applications 

2. Download script:
git clone https://github.com/hydex80/presence_detection_domoticz_fritzbox

3. Go to domoticz and make dummy hardware for your smartphones

settings > hardware > new > dummy give it a name for example smartphones
make as many virtual sensors as you want  by clicking on make virtual sensor
give type: switch and give it a name
after that go to devices
and write down the IDX of all the devices.

4. Write down the ip adres of your router and of your repeater (if you have any)  

5. Run the script with: sudo bash presence2.sh 

6. A installer will appear fill in all the questions and at the end copy the line for your crontab. (run crontab with: crontab -e) 
------------------------

That's it have fun!  





