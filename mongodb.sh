#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongo repo"

dnf install mongodb-org -y &>> $LOGS_FIL
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>> $LOGS_FILE
VALIDATE $? "Enable Mongod"

systemctl start mongod &>> $LOGS_FILE
VALIDATE $? "Start Mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod &>> $LOGS_FILE
VALIDATE $? "Restart Mongod"

print_total_time
