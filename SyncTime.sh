#!/bin/bash

##########################
###Sync time with Apple###
##########################
sntp -sS time.apple.com
systemsetup -settimezone America/Phoenix