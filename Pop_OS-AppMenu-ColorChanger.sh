#!/bin/bash

# Do not run this script as sudo!
# If the script is run as sudo, Zenity won't be able to work correctly.
if [[ $EUID -eq 0 ]]; then
	zenity --info --title="!!! Running with sudo !!!" --text="Please do not run this script with sudo!"
	exit 0
else
	zenity --warning --title="Warning !" --text="This script will ask for your root password.\nZenity won't work correctly if the script is directly run as sudo because the UI for the color picker will be broken.\nWith this solution, the script will store the password in a variable and use it after displaying the color picker gui.\nFeel free to check the code and read the description"
	zenity --question --title "Warning" --text "Are you sure you want to continue?" --ok-label="Yes" --cancel-label="No"

fi

# Loop for password input
while true; do

	# Prompt for sudo password
	password=$(zenity --password --title="Getting privileges")

	# Check if zenity was cancelled or closed and exit the script
    	if [[ $? -ne 0 ]]; then
		exit
	fi

	# Check if password is empty
	if [[ -z "$password" ]]; then
		zenity --error --text="Please input a password."
		continue
	fi

	# Check if sudo password is correct
	echo "$password" | sudo -Sk ls >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		zenity --error --text="Incorrect password. Try again."
		continue
	fi

	# Password is correct, break out of the loop
	break
done

# Default Pop!_OS background rgb values:
default_rgb_values="26,30,36"
default_opacity="1"

# Menu to choose to change or reset values
change_or_reset=$(zenity --list --title='Pop!_OS AppMenu Color Changer' --text="Please choose an option:" --radiolist --column "" --column "Options" FALSE "Change Color" FALSE "Reset Values")

# Check which option the user selected
if [[ $change_or_reset == "Change Color" ]]; then

	# Prompt user to choose a hex color
	color=$(zenity --color-selection --show-palette --title="Select Background Color" --color="chosencolor")
	
	# Check if the user canceled or closed the window
	if [[ $? -ne 0 ]]; then
		exit 0
	fi	

	# Extract the rgb values from the chosen color (only the numbers)
	rgb="${color#*(}"  # Remove everything before the first '('
	rgb="${rgb%)*}"    # Remove everything after the last ')'
	rgb_values=$(echo "$rgb" | awk -F ',' '{OFS=","; print $1, $2, $3}')  # Separate the number values with commas

	# Convert the number values without commas to hex
	IFS=',' read -r r g b <<< "$rgb_values"
	hex_values=$(printf "#%02x%02x%02x" "$r" "$g" "$b")

	# Display the selected colors
	zenity --info --title="Colors" --text="Chosen Rgb value: $rgb_values\nChosen Hex value: $hex_values"

	# Ask the user if they want to enable opacity
	zenity --question --text "Do you want to enable opacity in the App menu?"

	# Store the exit status of the Zenity dialog in a variable
	response=$?

	# Check the exit status to determine user's choice
	if [ $response -eq 0 ]; then # User chose "Yes" to enable opacity
		# Check what is the current opacity value the user has
		current_opacity=$(awk -F '[()]' '/background-color: rgba/ {split($2, arr, ","); if (length(arr) >= 4) print arr[4]; else print 0.3}' "/usr/share/gnome-shell/extensions/pop-cosmic@system76.com/dark.css")
		current_opacity=$(printf "%.0f" $(echo "$current_opacity*10" | bc)) # Workaround because zenity doesn't support float step values, only int. Multiply by 10.
		opacity=$(zenity --scale --title="Scale Example" --text="Select a value" --min-value=0 --max-value=10 --step=1 --value=$current_opacity)
		if [ $opacity -eq 10 ]; then
			opacity=1
		elif [ $opacity -eq 0 ]; then
			opacity=0
		else
			opacity=$(printf "%.1f" $(echo "scale=1; $opacity / 10" | bc)) # Workaround because zenity doesn't support float step values, only int. Divide by 10.
		fi
		
		# Write the chosen rgb and opacity values
		echo "$password" | sudo -S sed -i "2s|.*|background-color: rgba($rgb_values,$opacity);|" /usr/share/gnome-shell/extensions/pop-cosmic@system76.com/dark.css
	else
	exit 0
	fi

# If User choose to reset colors
elif [[ $change_or_reset == "Reset Values" ]]; then
	# Write the default rgb and opacity values
	echo "$password" | sudo -S sed -i "2s|.*|background-color: rgba($default_rgb_values,$default_opacity);|" /usr/share/gnome-shell/extensions/pop-cosmic@system76.com/dark.css
else
  exit 0
fi
