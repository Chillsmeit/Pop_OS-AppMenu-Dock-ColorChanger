#!/bin/bash

# Do not run this script as sudo!
# If the script is run as sudo, Zenity won't be able to work correctly.
if [[ $EUID -eq 0 ]]; then
	zenity --info --title="Running with sudo!" --text="Please do not run this script with sudo!"
	exit 0
fi

# Default Pop!_OS background rgb values:
default_app_rgb="26,30,36"
default_dock_hex="#33302f"

# Menu to choose to change or reset values
change_or_reset=$(zenity --list --title='Pop!_OS AppMenu Color Changer' --text="Please choose an option:" --radiolist --column "" --column "Options" FALSE "Change Color" FALSE "Reset Values")

# Check which option the user selected
if [[ $change_or_reset == "Change Color" ]]; then

	# Ask the user if they want to change AppMenu Color
	zenity --question --text "Do you want to change the App Menu Color?"

	# Store the exit status of the Zenity dialog in a variable
	app_color_response=$?

	# Check the exit status to determine user's choice
	if [ $app_color_response -eq 0 ]; then # User chose "Yes"

		# Prompt user to choose a hex color
		app_color=$(zenity --color-selection --show-palette --title="Select App Menu Background Color" --color="chosencolor")


		# Extract the rgb values from the chosen color (only the numbers)
		rgb="${app_color#*(}"  # Remove everything before the first '('
		rgb="${rgb%)*}"    # Remove everything after the last ')'
		rgb_values=$(echo "$rgb" | awk -F ',' '{OFS=","; print $1, $2, $3}')  # Separate the number values with commas

		# Convert the number values without commas to hex
		IFS=',' read -r r g b <<< "$rgb_values"
		hex_values=$(printf "#%02x%02x%02x" "$r" "$g" "$b")

		# Display the selected colors
		zenity --info --title="Colors" --text="Chosen Rgb value: $rgb_values\nChosen Hex value: $hex_values"
		
		# Write rgb values
		pkexec sudo -S sed -i "2s|.*|background-color: rgba($rgb_values,1);|" /usr/share/gnome-shell/extensions/pop-cosmic@system76.com/dark.css
		
	fi
	
	# Ask the user if they want to change AppMenu opacity
	zenity --question --text "Do you want to change opacity in the App menu?"

	# Store the exit status of the Zenity dialog in a variable
	app_opacity_response=$?

	# Check the exit status to determine user's choice
	if [ $app_opacity_response -eq 0 ]; then # User chose "Yes" to enable opacity
		
		# Check what is the current opacity value the user has
		current_app_opacity=$(awk -F '[()]' '/background-color: rgba/ {split($2, arr, ","); if (length(arr) >= 4) print arr[4]; else print 0.3}' "/usr/share/gnome-shell/extensions/pop-cosmic@system76.com/dark.css")
		current_app_opacity=$(printf "%.0f" $(echo "$current_app_opacity*10" | bc)) # Workaround because zenity doesn't support float step values, only int. Multiply by 10.
		chosen_app_opacity=$(zenity --scale --title="Scale Example" --text="Select a value" --min-value=0 --max-value=10 --step=1 --value=$current_app_opacity)
		
		if [ $chosen_app_opacity -eq 10 ]; then
			chosen_app_opacity=1
		elif [ $chosen_app_opacity -eq 0 ]; then
			chosen_app_opacity=0
		else
			chosen_app_opacity=$(printf "%.1f" $(echo "scale=1; $chosen_app_opacity / 10" | bc)) # Workaround because zenity doesn't support float step values, only int. Divide by 10.
		fi

		# Write the chosen opacity values
		pkexec sudo -S sed -E -i "2s|(background-color: rgba\([0-9]+,[0-9]+,[0-9]+),?[0-9.]*\)|\1,$chosen_app_opacity)|" /usr/share/gnome-shell/extensions/pop-cosmic@system76.com/dark.css
	fi

	# Ask the user if they want to change AppMenu opacity
	zenity --question --text "Do you want to change the Dock Color?"

	# Store the exit status of the Zenity dialog in a variable
	dock_color_response=$?

	# Check the exit status to determine user's choice
	if [ $dock_color_response -eq 0 ]; then # User chose "Yes"

		# Prompt user to choose a hex color for dock
		dock_color=$(zenity --color-selection --show-palette --title="Select Dock Color" --color="chosencolor")

		# Extract the rgb values from the chosen color (only the numbers)
		rgb="${dock_color#*(}"  # Remove everything before the first '('
		rgb="${rgb%)*}"    # Remove everything after the last ')'
		rgb_values=$(echo "$rgb" | awk -F ',' '{OFS=","; print $1, $2, $3}')  # Separate the number values with commas

		# Convert the number values without commas to hex
		IFS=',' read -r r g b <<< "$rgb_values"
		hex_values=$(printf "#%02x%02x%02x" "$r" "$g" "$b")

		# Display the selected colors
		zenity --info --title="Colors" --text="Chosen Rgb value: $rgb_values\nChosen Hex value: $hex_values"
		gsettings set org.gnome.shell.extensions.dash-to-dock background-color $hex_values
		gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color true
	fi

	# Ask the user if they want to enable dock opacity
	zenity --question --text "Do you want to enable opacity in the Dock?"

	# Store the exit status of the Zenity dialog in a variable
	dock_opacity_response=$?

	# Check the exit status to determine user's choice
	if [ $dock_opacity_response -eq 0 ]; then # User chose "Yes" to enable opacity
		# Check what is the current opacity value the user has
		current_dock_opacity=$(gsettings get org.gnome.shell.extensions.dash-to-dock background-opacity)
		current_dock_opacity=$(printf "%.0f" $(echo "$current_dock_opacity*10" | bc))
		chosen_dock_opacity=$(zenity --scale --title="Scale Example" --text="Select a value" --min-value=0 --max-value=10 --step=1 --value=$current_dock_opacity)
		if [ $chosen_dock_opacity -eq 10 ]; then
			chosen_dock_opacity=1
		elif [ $chosen_dock_opacity -eq 0 ]; then
			chosen_dock_opacity=0
		else
			chosen_dock_opacity=$(printf "%.1f" $(echo "scale=1; $chosen_dock_opacity / 10" | bc)) # Workaround because zenity doesn't support float step values, only int. Divide by 10.
		fi
		gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity $chosen_dock_opacity
	fi
		

	zenity --question --title "Restart Shell" --text "You need to restart the Gnome Shell to see your AppMenu changes.\nDo you want to proceed?" --ok-label="Yes" --cancel-label="No"
	restartshell=$?
	if [ $restartshell -eq 1 ]; then
		exit 0
	fi
		killall -3 gnome-shell
		exit 0

# If User chose to reset colors
elif [[ $change_or_reset == "Reset Values" ]]; then
	# Ask the user if they want to reset dock values
	zenity --question --text "Reset Dock?"

	# Store the exit status of the Zenity dialog in a variable
	dock_reset_response=$?

	# Check the exit status to determine user's choice
	if [ $dock_reset_response -eq 0 ]; then # User chose "Yes" to enable opacity
		gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 1
		gsettings set org.gnome.shell.extensions.dash-to-dock background-color '#33302f'
		gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color false
	fi
	
	# Ask the user if they want to reset AppMenu values
	zenity --question --text "Reset AppMenu?"
	
	# Store the exit status of the Zenity dialog in a variable
	app_reset_response=$?
	
	# Check the exit status to determine user's choice
	if [ $app_reset_response -eq 0 ]; then # User chose "Yes" to enable opacity

		# Write the default rgb and opacity values
		echo $default_app_rgb
		pkexec sudo -S sed -i "2s|.*|background-color: rgba(${default_app_rgb%.*});|" /usr/share/gnome-shell/extensions/pop-cosmic@system76.com/dark.css
		zenity --question --title "Restart Shell" --text "You need to restart the Gnome Shell to see your AppMenu changes.\nDo you want to proceed?" --ok-label="Yes" --cancel-label="No"
		restartshell=$?
		if [ $restartshell -eq 1 ]; then
        		exit 0
		fi
			killall -3 gnome-shell
			exit 0
	fi
fi
