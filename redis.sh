#!/bin/bash

source ./common.sh
app_name=redis

check_root

dnf module disable redis -y &>> $LOGS_FILE
VALIDATE $? "Disabled redis default version"

dnf module enable redis:7 -y &>> $LOGS_FILE
VALIDATE $? "Enable redis current version"

dnf install redis -y &>> $LOGS_FILE
VALIDATE $? "Installing Redis ..."

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf 
VALIDATE $? "Allowing remote connections"

systemctl enable redis &>> $LOGS_FILE
VALIDATE $? "Enabling redis"

systemctl start redis &>> $LOGS_FILE
VALIDATE $? "Start redis"