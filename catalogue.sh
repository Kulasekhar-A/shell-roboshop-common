#!/bin/bash

app_name=catalogue
source ./common.sh

check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo"

dnf install mongodb-mongosh -y &>> $LOGS_FILE
VALIDATE $? "Install mongodb"

INDEX=$(mongosh --host $MONGODB_HOST --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")' )
if [ $INDEX -le 0 ]; then
   mongosh --host $MONGODB_HOST </app/db/master-data.js
   VALIDATE $? "Loading products"
else
   echo -e "Products already loaded ... $Y skipping $N"
fi

print_total_time
