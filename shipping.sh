#!/bin/bash

app_name=shipping
source ./common.sh

check_root
app_setup
nodejs_setup
java_setup
systemd_setup

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>> $LOGS_FILE
VALIDATE $? "Copying shipping service"

systemctl daemon-reload &>> $LOGS_FILE
VALIDATE $? "Reload the service"

systemctl enable shipping &>> $LOGS_FILE
VALIDATE $? "Enable the shipping service"

systemctl start shipping &>> $LOGS_FILE
VALIDATE $? "Start the shipping service"

dnf install mysql -y  &>> $LOGS_FILE
VALIDATE $? "Install mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then
  mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
  mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql 
  mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
  VALIDATE $? "Loaded data into mysql"
else
  echo -e "data is already loaded ...$Y skipping $N"
fi

print_total_time