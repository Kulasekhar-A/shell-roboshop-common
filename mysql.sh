#!/bin/bash

source ./common.sh
app_name=mysql

check_root

dnf install mysql-server -y &>> $LOGS_FILE
VALIDATE $? "Installing Mysql...."

systemctl enable mysqld &>> $LOGS_FILE
VALIDATE $?  "Enable mysqld"

systemctl start mysqld &>> $LOGS_FILE
VALIDATE $? "Start mysqld"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGS_FIL
VALIDATE $? "set root password for mysql"



print_total_time