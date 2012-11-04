#!/bin/sh
# Honeypot Install script
# Installs Dionaea, Glastopf and Kippo
# Works only on Ubuntu-Server 10.0.4.1
#
# Greg Martin - gregcmartin@gmail.com
# http://infosec20.blogspot.com
#
#
####### Install Dionaea Honeypot #########
sudo add-apt-repository ppa:honeynet/nightly
sudo apt-get update
sudo apt-get -y upgrade
sleep 5
sudo apt-get -y install dionaea p0f
sleep 5
sudo mkdir -p /var/dionaea/wwwroot
sudo mkdir -p /var/dionaea/binaries
sudo mkdir -p /var/dionaea/log
sudo chown -R nobody:nogroup /var/dionaea/
sudo mv /etc/dionaea/dionaea.conf.dist /etc/dionaea/dionaea.conf
sudo sed -i 's/var\/dionaea\///g' /etc/dionaea/dionaea.conf
sudo sed -i 's/log\//\/var\/dionaea\/log\//g' /etc/dionaea/dionaea.conf
sudo sed -i 's/"uniquedownload",/"uniquedownload","submit_http",/g' /etc/dionaea/dionaea.conf
sudo sed -i 's/url = "" /url = "http:\/\/martincyber.com:8080\/submit"/' /etc/dionaea/dionaea.conf
sudo sed -i 's/"http",//g' /etc/dionaea/dionaea.conf
sudo sed -i 's/levels = "all"/levels = "warning,error"/g' /etc/dionaea/dionaea.conf
#sudo echo "killall dionaea; rm -rf /var/dionaea/log/*;sudo /usr/bin/dionaea -c /etc/dionaea/dionaea.conf -w /var/dionaea -u nobody -g nogroup -D" >> /etc/cron.daily/logrotate
sudo dionaea -c /etc/dionaea/dionaea.conf -w /var/dionaea -u nobody -g nogroup -D

######## Move SSH to port 2222 ############
sudo sed -i 's/Port 22/Port 2222/g' /etc/ssh/sshd_config
sudo service ssh reload

######## Install glastopf honeypot ##############
sudo apt-get -y install git-core subversion python-openssl build-essential make python-chardet
cd /opt && sudo git clone git://github.com/rep/evnet.git
cd /opt/evnet
sudo python setup.py install 
cd /opt && sudo svn co svn://glastopf.org:9090/glaspot glaspot
cd /opt/glaspot/trunk/sandbox && sudo make
cd /opt/glaspot/trunk
sudo sed -i 's/8080/80/' glastopf.cfg
sudo python /opt/glaspot/trunk/webserver.py &


######## Install kippo ssh honeypot #############
sudo apt-get -y install python-dev openssl python-openssl python-pyasn1 python-twisted subversion authbind
sleep 5
sudo useradd -s /bin/false -d /home/kippo -m kippo
cd /home/kippo
sudo svn checkout http://kippo.googlecode.com/svn/trunk/ .
sudo touch /etc/authbind/byport/22
sudo chown kippo:kippo /etc/authbind/byport/22
sudo chmod 777 /etc/authbind/byport/22
sudo mv kippo.cfg.dist kippo.cfg
sudo sed -i 's/twistd -y kippo.tac -l log\/kippo.log --pidfile kippo.pid/authbind --deep twistd -y kippo.tac -l log\/kippo.log --pidfile kippo.pid/g' start.sh
sudo chmod 0440 /etc/sudoers
sudo chmod g+r /etc/sudoers
sudo echo 'kippo ALL=(ALL:ALL) ALL' >> /etc/sudoers
sudo chown -R kippo:kippo /home/kippo/
sudo sed -i 's/ssh_port = 2222/ssh_port = 22/g' kippo.cfg
sudo -u kippo ./start.sh

