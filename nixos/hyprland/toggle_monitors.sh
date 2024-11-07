#!/bin/bash

# Получаем информацию о подключенных мониторах
monitors_on=$(hyprctl monitors | grep "dpmsStatus: 1" | wc -l)
echo $monitors_on
if [ $monitors_on -gt 0 ]; then
    # Если мониторы включены, выключаем их
    hyprctl dispatch dpms off
else
    hyprctl dispatch dpms on
fi

