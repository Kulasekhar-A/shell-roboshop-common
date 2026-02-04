#!/bin/bash

source ./common.sh
app_name=rabbitmq

check_root

cp $SCRIPT_DIR/rabbitmq.repo  /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Copying rabitmq repo"

dnf install rabbitmq-server -y &>> $LOGS_FILE
VALIDATE $? "Install Rabbitmq"

systemctl enable rabbitmq-server &>> $LOGS_FILE
VALIDATE $? "Enable the rabbitmq server"

systemctl start rabbitmq-server &>> $LOGS_FILE
VALIDATE $? "Start the rabbitmq server"

id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>> $LOGS_FILE
    VALIDATE $> "Creating system user"
else
   echo -e "Already exist ... $Y Skipping it $N"

fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGS_FILE
VALIDATE $? "set permissions to the user"

print_total_time