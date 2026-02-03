#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop-common"
LOGS_FILE="$LOGS_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
mkdir -p  $LOGS_FOLDER
SCRIPT_DIR=$PWD
MONGODB_HOST="mongodb.annuru.online"
MYSQL_HOST="mysql.annuru.online"
START_TIME=$(date +%s)

echo "$(date "+%y-%m-%d %H:%M:%S") | script start executing at : $(date)" | tee -a $LOGS_FILE

check_root(){
if [ $USERID -ne 0 ]; then
  echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
  exit 1
fi

}

VALIDATE(){
   if [ $1 -ne 0 ]; then
       echo -e "$(date "+%y-%m-%d %H:%M:%S") | $2 ...$R FAILURE  $N" | tee -a $LOGS_FILE
       exit 1
   else
       echo -e "$(date "+%y-%m-%d %H:%M:%S") | $2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
   fi
}

nodejs_setup(){
    dnf module disable nodejs -y &>> $LOGS_FILE
    VALIDATE $? "Disabling Nodejs default version"

    dnf module enable nodejs:20 -y &>> $LOGS_FILE
    VALIDATE $? "Enable version"

    dnf install nodejs -y &>> $LOGS_FILE
    VALIDATE $? "Install Nodejs"

    npm install &>> $LOGS_FILE
    VALIDATE $? "Installing NPM"
}

app_setup(){
        id roboshop &>> $LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
        VALIDATE $> "Creating system user"
    else
    echo -e "Already exist ... $Y Skipping it $N"

    fi

    mkdir -p /app &>> $LOGS_FILE
    VALIDATE $? "App directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>> $LOGS_FILE
    VALIDATE $? "Download the code"

    cd /app &>> $LOGS_FILE
    VALIDATE $? "Moving to app directory"

    rm -rf /app/*
    VALIDATE $? "Removing existing code"

    unzip /tmp/$app_name.zip &>> $LOGS_FILE
    VALIDATE $? "Unzip the code"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Copying $app_name service"

    systemctl daemon-reload &>> $LOGS_FILE
    VALIDATE $? "Reload the service"

    systemctl enable $app_name &>> $LOGS_FILE
    VALIDATE $? "Enable the $app_name service"

    systemctl start $app_name &>> $LOGS_FILE
    VALIDATE $? "Start the $app_name service"
}

java_setup(){
    dnf install maven -y &>> $LOGS_FILE
    VALIDATE $? "Installing Maven ..."

    mvn clean package &>> $LOGS_FILE
    VALIDATE $? "Clean the default package"

    mv target/$app_name-1.0.jar $app_name.jar &>> $LOGS_FILE
    VALIDATE $? "Renaming jar file"

}

restart_setup(){
    systemctl restart $app_name  &>> $LOGS_FILE
    VALIDATE $? "Restart the $app_name"
}
print_total_time(){

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo "$(date "+%y-%m-%d %H:%M:%S") | script executed in : $(date)" | tee -a $LOGS_FILE
}