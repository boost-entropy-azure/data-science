#!/bin/bash
# This script takes the mqtt-connector.conf file that contains the configuration 
# settings for the MQTT to Azure Event Hubs connector and uploads it to the file
# share so the container can access it.

az storage file upload --share-name $1 --account-name $2 --account-key $3 --source ../config/mqtt-connector.conf