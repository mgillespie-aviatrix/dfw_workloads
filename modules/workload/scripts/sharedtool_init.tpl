#!/bin/bash

#Install bash

apt -y install apache2


#Setting up pingtest python script
cat << EOF > /var/www/html/pingtest.py
#!/usr/bin/env python3

import os
import re
import socket
import sys
import logging
import logging.handlers


syslogger = logging.getLogger("Syslogger")
syslogger.setLevel(logging.INFO)
syslog_handler = logging.handlers.SysLogHandler(address =('SHARED_SERVER_IP', 514))
syslogger.addHandler(syslog_handler)


f = open("/tmp/hostlist_with_tags.txt", "r")

my_hostname = socket.gethostname()
my_tags = "undefined"

for line in f.readlines():
    m = re.match("(.*?)\|(.*?)\|(.*)", line)
    hostname = m.group(1)
    hostip = m.group(2)
    tags = m.group(3)

    if hostname == my_hostname:
        my_tags = tags

f.seek(0)

for line in f.readlines():   
    m = re.match("(.*?)\|(.*?)\|(.*)", line)
    if m:
        hostname = m.group(1)
        hostip = m.group(2)
        tags = m.group(3)

        response = os.system(f"ping -W 2 -c 1 {hostip} >/dev/null")
        if response == 0:
            syslogger.info(f"{my_hostname} ({my_tags}) CAN reach {hostname} ({tags})")
        else:
            syslogger.info(f"{my_hostname} ({my_tags}) CANNOT reach {hostname} ({tags})")


f.close()
EOF

#Update IP address
export IP=$(hostname -i)
sed -i -r "s/SHARED_SERVER_IP/$IP/" /var/www/html/pingtest.py


echo "Setting up systemd"

#Setup the systemd service
cat << EOF > /etc/systemd/system/pingtest.service
[Unit]
Description=Test Connectivity in DFW Environments

[Service]
ExecStart=/usr/bin/python3 /tmp/pingtest.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

/usr/bin/systemctl daemon-reload
/usr/bin/systemctl enable pingtest.service
/usr/bin/systemctl start pingtest.service

#Update Rsyslog to listen on UDP:514
sed -i -r "s/#module\(load=\"imudp\"\)/module\(load=\"imudp\"\)/" /etc/rsyslog.conf 
sed -i -r "s/#input\(type=\"imudp\"/input\(type=\"imudp\"/" /etc/rsyslog.conf 
systemctl restart rsyslog




#Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash 

touch /var/ww/hostlist_with_tags.txt
touch /tmp/hostlist_with_tags.txt