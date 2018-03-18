#!/bin/bash 

upgrade_and_time_check () {
    cat << EOF
############################
Upgrading system and 
checking to see if synchronised 
to an NTP server
############################
EOF

sleep 2

sudo apt update && sudo apt upgrade -y 
timedatectl
}


service_user_no_password () {
cat << EOF
########################################################
Creating a root user called stack which will be allowed
to run all commands from all hosts without a password
#######################################################
EOF
sleep 5

    sudo useradd  -s /bin/bash -d /opt/stack -m stack #creates a user called stack with the default shell being bash 
#creates home directory as /opt/stack 
cat << EOF >>stack
stack ALL=(ALL) NOPASSWD: ALL
EOF

echo "moving file stack to sudoers.d directory"
sudo chown root:root stack
sudo mv stack /etc/sudoers.d/
#ALL means runs commands from any host on the left of the = sighn
#(ALL) means can run commands as all users and groups
#NOPASSWD means that we do not need to put in the password
#ALL at the end means that we can run all commands

echo "checking to see if user stack is able to sudo"
sudo su -l stack
sudo /etc/shadow
}

devstack_config () {
    cat << EOF 
##########################
Cloning dev stack repo 
##########################
EOF 

sleep 2 

git clone https://github.com/openstack-dev/devstack.git
cd devstack

cat << EOF
##############################
Settintg up openstack variables
##############################
EOF

sleep 2

cat << "EOF" >>local.conf
[[local|localrc]]
ADMIN_PASSWORD=Password1
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD
HOST_IP=10.0.0.43
EOF
sudo sed -i '2d' /etc/hosts
sudo sed -i '1 a 10.0.0.43\t openstack' /etc/hosts #\t means tab
./stack.sh

cat <<EOF 
#######################################
Sourcing openrc To allow for
authentication to the openstack system
#######################################
EOF 
sleep 2
source openrc
}



overall_setup () {
    upgrade_and_time_check
    service_user_no_password
    devstack_config
}


cat << EOF
############################
This script is designed 
to install openstack devstack
############################
EOF
sleep 2
overall_setup
