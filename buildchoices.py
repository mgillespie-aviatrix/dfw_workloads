#!/usr/bin/env python3
import os
import subprocess
import json
import re

f = open("hostlist.txt", "r")
w = open("dfw-realtime.sh", "w")

w.write("#!/bin/bash\n")
w.write("items=(")
i = 0
for line in f.readlines():
    i += 1
    m = re.match("(.*?)\|(.*)", line)
    hostname = m.group(1)
    hostip = m.group(2)

    w.write(f'{i} "{hostname}"\n')
w.write(')\n')
f.seek(0)
w.write('while choice=$(dialog --title "DFW Realtime" --menu "Please select host" 30 50 15 "${items[@]}" 2>&1 >/dev/tty)\n')
w.write('do\n')
w.write('case $choice in \n')

i = 0
for line in f.readlines():
    i += 1
    m = re.match("(.*?)\|(.*)", line)
    hostname = m.group(1)
    hostip = m.group(2)

    w.write(f'{i}) clear; tail -f /var/log/syslog | egrep "[0-9:]+ {hostname}" ;;\n')
w.write('esac\n')
w.write('done\n')
