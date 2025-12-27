#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log
MONGODB_HOST=mongodb.vamsimln.online
SCRIPT_DIRECTORY=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e " $2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e " $2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}


dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable Node"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable Node"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Instaling node"


id roboshop
if [ $? -ne 0 ]; then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating System user"
else
    echo "User already exist...$Y Skipping $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Catalouge Application"

cd /app 
VALIDATE $? "Changing App Directory"

rm -rf /app/*
VALIDATE$? ""Removing Existing Code
unzip /tmp/catalogue.zip
VALIDATE $? "Unzip Catalouge"

npm install 
VALIDATE $? "Install Dependecies"

cp $SCRIPT_DIRECTORY/Catalouge.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copy systemctl service"

systemctl enable catalogue 
VALIDATE $? "Enable Catalouge"

cp $SCRIPT_DIRECTORY/mongo.repo/etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy Mongo repo"

dnf install mongodb-mongosh -y
VALIDATE $? "Install MongoDb Client"

mongosh --host $MONGODB_HOST </app/db/master-data.js
VALIDATE $? "Load Catalouge products"

systemctl restart Catalouge
VALIDATE $? "Restarting Catalouge"