#!/bin/bash

set -euxo pipefail

systemImg="$(readlink -f -- "$1")"

size=$(LD_LIBRARY_PATH=. ./simg2img_simple-host < "$systemImg" |wc -c)
adb push lptools /data/local/tmp/
adb push simg2img_simple /data/local/tmp/
adb shell 'su -c "/data/local/tmp/lptools remove system_phh"'
adb shell 'su -c "/data/local/tmp/lptools create system_phh '$size'"'
adb shell 'su -c "/data/local/tmp/lptools unmap system_phh"'
dmDevice=$(adb shell 'su -c "/data/local/tmp/lptools map system_phh"'|grep -oE '/dev/block/[^ ]*')
pv $systemImg | adb shell -T -e none 'su -c "/data/local/tmp/simg2img_simple > '$dmDevice'"'
adb shell 'su -c "/data/local/tmp/lptools replace system_phh system"'
adb reboot
