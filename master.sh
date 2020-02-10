#!/bin/bash

# Goal: 
# To create a script that finds the os the system is using and downloads & runs the script


# Test to see if user is running with root privileges.
if [[ "${UID}" -ne 0 ]]
then
 echo 'Must execute with sudo or root' >&2
 exit 1
fi

# Welcome
