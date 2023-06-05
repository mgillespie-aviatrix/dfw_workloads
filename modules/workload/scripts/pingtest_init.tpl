#!/bin/bash

#Install bash

apt -y install apache2

#Install pingtest_upgrade script
cat << EOF > /usr/local/bin/pingtest_upgrade.sh
#!/bin/bash
date >> /tmp/startuptime

cd /tmp/
/usr/bin/wget --tries=1 --connect-timeout=5 http://${shared_server_ip}/hostlist_with_tags.txt -O /tmp/hostlist_with_tags.txt
/usr/bin/wget --tries=1 --connect-timeout=5 http://${shared_server_ip}/pingtest.py -O /tmp/pingtest.py
EOF

chmod +x /usr/local/bin/pingtest_upgrade.sh

#Update Crontab and run pingtest_upgrade for the first time
echo "@reboot /usr/local/bin/pingtest_upgrade.sh" | crontab -
/usr/local/bin/pingtest_upgrade.sh

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