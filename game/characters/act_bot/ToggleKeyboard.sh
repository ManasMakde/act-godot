#!/bin/bash

fconfig=".keyboard" 
id=19

if [ ! -f $fconfig ]; then
  echo "Creating config file"
  echo "enabled" > $fconfig
  var="enabled"
else
  read -r var< $fconfig
  echo "keyboard is : $var"
fi

if [ "$var" = "disabled" ]; then
  notify-send -i "Enabling keyboard..." \ "ON - Keyboard connected !";
  echo "enable keyboard..."
  xinput enable $id
  echo "enabled" > $fconfig
elif [ "$var" = "enabled" ]; then
  notify-send -i "Disabling Keyboard" \ "OFF - Keyboard disconnected";
  echo "disable keyboard"
  xinput disable $id
  echo 'disabled' > $fconfig
fi
