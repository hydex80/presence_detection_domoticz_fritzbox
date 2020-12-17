presence_detection.sh

# Presence detection domoticz for fritzbox routers

script Presence detection for domoticz  & Fritzbox v2.3
created by g.j funcke - 26  jul 2019

making use of  fritzconnection  url: https://pypi.org/project/fritzconnection/

dependencies: python lxml, jq and requests

tested with: Fritzbox 7581 should work with all (fritzbox)routers who are supporting TR-064 protocol.
works on ubuntu. 

Background information:
Since i was not happy with the available presence detection scripts which are worked not very well with iPhone. I made a presence detection script using the TR-064 protocol of my Fritzbox router and get direct information of the router itself.
This saves battery of your smartphone because there is no need of pinging all the time and its more accurate, because the router is made for having the correct information about network devices.

This script is tested with a fritzbox 7581 router but should be working with more routers who has a tr064 protocol implementation. 

What the script does is making use of the python script "fritzconnection" Thnx a lot to Author: Klaus Bremer
sending a request to the router, Get all the available WLAN devices and its state. It is very fast and reliable. When I set my iPhone in airplane mode after 2 seconds I get the good status. When my iPhone gets in screensaver modus it stays Online in Domoticz (which is fine:) 
Since I don't want to send to many requests to domoticz I compare the current state of domoticz with the state of de router. Are they similar? Then I do nothing. Are they different I update the switch state in domoticz

When you have a Fritzbox Repeater. You should also add this to the script. The script will look for your devices on the fritzbox and on the repeater. 
You can find thIfe repeaters Ip adres by going to: http://fritz.repeater use the same password as logging in on your router. You can login to your router to go to http://fritz.box

Would be nice to have some feedback, maybe you can test this script on your own fritzbox. Maybe its also working on other routers wich are using the TR-064 protocol standard. feel free to let me know if it works

-------------------------
# Installation instructions:

Make sure to give your devices including your fritzbox repeater (if you have any) a static ip in your router http://fritz.box Login, and go to Home network > network and then click on the device you want to use > click on pencil and check: Always assign this network device the same IPv4 address, we use this ip to target the devices in the script. 



1. Make sure to give your devices including your fritzbox repeater (if you have any) a static ip in your router http://fritz.box Login, and go to Home network > network and then click on the device you want to use > click on pencil and check: Always assign this network device the same IPv4 address, we use this ip to target the devices in the script. If you have a iphone/ipad with iOS14 or higher installed, please check out the option private adress in your  wifi settings (go to general -> settings> wifi > select current wifi adress > deselect private adress. 

2. Activate on your router the TR-064 protocol on fritzbox it is in >home network > network > network settings > Allow access for applications 

3. Download script:
```sudo git clone https://github.com/hydex80/presence_detection_domoticz_fritzbox```

4. Write down the ip adres of your router and of your repeater (if you have any)

5. Write down the mac adresses of your devices you want to monitor. 

6. Run the script with: ```sudo bash presence_detection.sh``` 

7. A installer will appear fill in all the questions and at the end copy the line for your crontab. (run crontab with: crontab -e) 
------------------------

# Frequently asked questions(FAQ)
**Since iOS14 and newer updates on Android the script is not working. Because of Mac adress randomization.**

For privacy reasons. Apple and Google are randomize your mac adress so public services can not tracking you when you are shopping or walking by.
Since the presence detections only works within your home network this has no function for privacy. (unless you have something to hide for your roommates ;-)  

You can disable it for a certain network. On other networks the randomization continues. 

Apple iOS 14 & Later:
Ensure your device is connected to a Wi--Fi Network
Open the "Settings app", then tap "Wi-Fi"
Tap the "information button" next to your Plume network
Tap on the "Use private Address" toggle to turn it off
After, a privacy warning will pop-up


Google Pixel / Motorola / Other Androids:
Open the Settings app
Select Network and Internet
Select WiFi
Connect to the Wireless network
Tap the gear icon next to the current connection
Select Advanced
Select Privacy
Select "Use device MAC"

Samsung Galaxy:
Navigate to "Settings"
Select "Connections"
Select "WiFi"
Select "the Wireless Network you wish to connect to"
Tap the gear shaped icon next to the network you connected to
Select "Advanced"
On the next screen there is a menu labeled "MAC Address Type".
Tap on "MAC Address Type"
Select “Use Phone/Device MAC”

**1.How can i do fresh re-install?:**

1. if you didn't, first delete old dummy device: go to domoticz > settings > hardware > delete dummy device presence_detection
2. go to ssh 
make a new directory for example test. move over to this directory 
and run: 

```
sudo git clone https://github.com/hydex80/presence_detection_domoticz_fritzbox
```
then reinstall the script with: 
```
sudo bash presence_detection.sh
```
you can also run to override : 

```
sudo bash presence_detection.sh install 
```
**2. The script is not working, status are not updated correctly, what can i do?**

1. Check of all dependencies are installed run:  
```
sudo apt-get install python jq python-lxml python-requests
```
2. If its still not working check ip adresses and mac adresses of you devices inside config file. If there is no config file something is wrong, reinstall the script with: ```sudo bash presence_detection.sh install```  
3. Check if there is a dummy hardware goto:
```
domoticz > settings> hardware >
- check if "presence_detection" dummy hardware is available 
```
if there is no hardware with name presence_detection something went wrong 
4.check if password of domoticz is set correctly inside config.txt file: 
```
reinstall with: sudo bash presence_detection.sh install 
```
5.check if there is dummy devices named with the devices you make 
```
domoticz > settings > devices > click on tab hardware and look for presence_detection 
-check if there are dummy devices set 
```
6.If its still nog working goto https://www.domoticz.com/forum/viewtopic.php?f=63&t=26599 or send me a pm (funky)

Or add the dummy hardware manually see step 5.

**3. Sometimes the device status is set correctly and sometimes is isnt, what is happening?** 

This happens when you have a repeater and your devices switches over to the repeater. Make sure there is a ip set
in the config file for the repeater. If you havent have a repeater and this still occurs goto the domoticz forum and let me know. https://www.domoticz.com/forum/viewtopic.php?f=63&t=26599
**3a. Still didn't got it working:**
run: sudo bash presence_detection.sh debug and see what happens. are there any errors? 

**4. I want to uninstall the script how can i do this?**

1.first delete old dummy device: go to domoticz > settings > hardware > delete dummy device presence_detection
2.Edit your crontab file and remove the line of the script
3.remove the directory with the script 
4.If you want to remove dependencies (look out if you're not sure if it used by something else) run:
```
sudo apt-get remove python jq python-lxml python-requests
```
**5.how can i add the dummy hardware manually?**
goto domoticz > settings > hardware > new > dummy give it a name for example smartphones
make as many virtual sensors as you want  by clicking on make virtual sensor
give type: switch and give it a name
after that go to devices
and write down the IDX of all the devices.
Add them to the config.txt file. (sudo nano config.txt) 
seperate the (multiple) devices with a space like: device_idx=(493 494)

**6. I want do debugging the proces how can i do that?** 

for debugging:
```run: sudo bash presence_detection.sh debug```

**7. I want to make the script executable how can i do that?**

if you don't want to use sudo  make the script executable with:
```sudo chmod +x presence_detection.sh``` 
after that you can run the script with
```bash presence_detection.sh```

**8.There are multiple dummy hardware named presence_detection in domoticz, how can this be?** 

You have run the install script twice or more. The script is not detecting if there is already a dummy device inside domoticz
everytime you run the install script it will make a new dummy hardware with devices. Can can remove the old ones manually
go to domoticz > settings > hardware > delete dummy device presence_detection

**9. I reinstalled domoticz and restore its backup, how can i use this script again?**
Goto settings> devices > click tab hardware en write down all the idx of the devices. In the installation script choose N on the question automatically install dummy devices and fill in your idx afterwards

**10. How can install a new version of the script**
1. make a backup of your config.txt file 
2. download the script
```
sudo git clone https://github.com/hydex80/presence_detection_domoticz_fritzbox
```
3. restore the config file inside the map and you're up and running again. 

**11. I get an config is corrupt message**
The config is corrupt message appears when you dont enter a value within the install script. Re-run the install script and enter all values. 



