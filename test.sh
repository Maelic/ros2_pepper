#!/bin/bash


START_TIME=$SECONDS
if sleep 5 ; then
    ELAPSED_TIME=$((($SECONDS - $START_TIME)/60))
    pushover_notification.sh "compilation took $ELAPSED_TIME min" "successfully completed"
else
    ELAPSED_TIME=$((($SECONDS - $START_TIME)/60))
    pushover_notification.sh "compilation took $ELAPSED_TIME min" "failed"
fi

sudo shutdown -h now
