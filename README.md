# Description

This bash script allows you to change the background color & opacity of the Applications Menu and the Dock in Pop!_OS 22.04.<br>

Just select a color using the color-picker dialog box and select the opacity using the slider gui.<br>
The opacity values range from 0 to 10 which in reality goes from 0 to 1.<br>

## Dependencies:
```
sudo apt-get update && sudo apt-get install dbus-x11 zenity wget
```

## ⚠️ Warning:
Zenity won't work properly if the script is directly run as sudo because the GUI for the color picker will be broken.<br>
Please run the script without sudo. It will prompt your root password when it needs to overwrite the values.

## Instructions:

Download the script in terminal with:
```
wget https://raw.githubusercontent.com/Chillsmeit/Pop_OS-AppMenu-Dock-ColorChanger/main/Pop_OS-AppMenu-Dock-ColorChanger.sh
```
Make the script executable:
```
chmod +x Pop_OS-AppMenu-Dock-ColorChanger.sh
```
Run the script **without** sudo privileges:
```
./Pop_OS-AppMenu-Dock-ColorChanger.sh
```
**After choosing your desired color or opacity, you have to restart the shell:**
`Alt+F2`+`r` and Enter

## Screenshots:
![19-06-2023_4](https://github.com/Chillsmeit/Pop_OS-AppMenu-ColorChanger/assets/93094077/33b6f03a-446f-4ad4-b215-22eb6d94823c)
