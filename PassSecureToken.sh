#!/bin/bash

#######################
###Admin credentials###
#######################
adminUser=$4
adminPassword=$5

##############################################################
###This will store the logged in user's name to a variable.###
##############################################################
userName=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

##############################################################################
###This will prompt the user for their password and store it in a variable.###
##############################################################################
userPassword=$(osascript -e '
tell application "Finder"
   display dialog "Please enter your Computer password." with hidden answer default answer ""
   set userPassword to the (text returned of the result)
end tell')

#####################################################################################################
###Store the output of the sysadminctl command into a variable to use it for error handling later.###
#####################################################################################################
output=$(sudo sysadminctl -adminUser "$adminUser" -adminPassword "$adminPassword" -secureTokenOn $userName -password $userPassword 2>&1)

######################################################################################################
###Error handling to see if the password entered is the same password used to log into the machine.###
######################################################################################################

#############################################################################################
###Searches for the output "Done". If this exist then the sysadminctl command will be ran.###
#############################################################################################
if [[ $output == *"Done"* ]]; then
	############################################################################################################################
    ###Command used to provide the user a secureToken. The admin user must have a secure token or this command will not work.###
    ###You can always check the JAMF policy logs to see if the user is experiencing an issue.###################################
    ############################################################################################################################
	sysadminctl -adminUser "$adminUser" -adminPassword "$adminPassword" -secureTokenOn $userName -password $userPassword
    
    ##############################
    ###GUI dialog for the user.###
    ##############################
    title='MacOS FileVault Encryption'
	osascript -e "display dialog \"Your password has been successfully synced with FileVault!\" buttons {\"OK\"} default button \"OK\" with title \"$title\""
else
	##############################
    ###GUI dialog for the user.###
    ##############################
    title='MacOS FileVault Encryption'
	osascript -e "display dialog \"The password entered did not match your password on this computer! Please quit and re-run the Self-Service policy to try again.\" buttons {\"Quit (Your password was not synced!)\"} default button \"Quit (Your password was not synced!)\" with title \"$title\""
fi
