#!/bin/bash
user=$(id -u)

if [ $user -ne 0 ]; then
   echo "Please run the script as root user access"
   exit 1
 fi
