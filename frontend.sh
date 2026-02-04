#!/bin/bash

app_name=frontend
source ./common.sh

check_root

dnf module disable nginx -y &>> $LOGS_FILE
VALIDATE $? "Disabling Nginx default version"

dnf module enable nginx:1.24 -y &>> $LOGS_FILE
VALIDATE $? "Enable Nginx version"

dnf install nginx -y &>> $LOGS_FILE
VALIDATE $? "Installing Nginx ..."

systemctl enable nginx &>> $LOGS_FILE
VALIDATE $? "Enable nginx"

systemctl start nginx &>> $LOGS_FILE
VALIDATE $? "Starting nginx"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOGS_FILE
VALIDATE $? "Download the code"

cd /usr/share/nginx/html &>> $LOGS_FILE
VALIDATE $? "Moving the /usr/share/nginx/html directory"

rm -rf /usr/share/nginx/html/* &>> $LOGS_FILE
VALIDATE $? "Remove the default content inside web server"

unzip /tmp/frontend.zip &>> $LOGS_FILE
VALIDATE $? "Unzip the code"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>> $LOGS_FILE
VALIDATE $? "copying nginx configure" 

restart_setu

print_total_time