# Description

This bash script allows you to change the background color of the Applications menu in Pop!_OS 22.04.<br>
*I'm not sure if it works in other versions.*

Just select a color using the color-picker dialog box and select the opacity using the slider gui.<br>
The opacity values range from 0 to 10 which in reality goes from 0 to 1.<br>

## Dependencies:
```
sudo apt-get update && sudo apt-get install dbus-x11 zenity wget
```

## ⚠️ Warning:
Zenity won't work properly if the script is directly run as sudo because the GUI for the color picker will be broken.<br>
Due to this reason, the workaround is to ask and store the root password in a variable and use it **after** displaying the color picker gui to be able to write the values.<br>
Feel free to check the code if you have security concerns.

## Instructions:

Download the script in terminal with:
```
wget https://raw.githubusercontent.com/Chillsmeit/Pop_OS-AppMenu-ColorChanger/main/Pop_OS-AppMenu-ColorChanger.sh
```
Make the script executable:
```
chmod +x Pop_OS-AppMenu-ColorChanger.sh
```
Run the script **without** sudo privileges:
```
./Pop_OS-AppMenu-ColorChanger.sh
```
**After choosing your desired color or opacity, you have to restart the shell:**
`Alt+F2`+`r` and Enter
