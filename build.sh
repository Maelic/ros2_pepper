#!/bin/bash


START_TIME=$SECONDS
if ./clean.sh && ./prepare_requirements_ros1.sh && ./build_ros1_dependencies.sh && ./build_ros1.sh ; then
    ELAPSED_TIME=$((($SECONDS - $START_TIME)/60))
    ./pushover_notification.sh "compilation took $ELAPSED_TIME min" "successfully completed"
else
    ELAPSED_TIME=$((($SECONDS - $START_TIME)/60))
    ./pushover_notification.sh "compilation took $ELAPSED_TIME min" "failed"
fi

# sudo shutdown -h now
