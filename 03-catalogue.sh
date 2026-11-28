#!/bin/bash/
if [ $USERID -ne 0 ]; then
   echo echo "Please run this script with root access"
   exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
    echo " $2 .. FAILURE"

    else
    echo "$2 .. SUCCESS"
    fi
}

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y
VALIDATE $? "Installing NodeJS:20"

id roboshop 
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop 
    VALIDATE $? "Creating roboshop system user"
else
    echo  "System user roboshop already created ...  SKIPPING"
fi

rm -rf /app
VALIDATE $? "Removing existing code"

rm -rf /tmp/catalogue.zip
VALIDATE $? "Removed catalogue zip"

mkdir -p /app  
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
cd /app 
unzip /tmp/catalogue.zip 
VALIDATE $? "Downloaded and extracted catalogue code"

npm install 
VALIDATE $? "Installing dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
# cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
 VALIDATE $? "Created systemctl service"

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Added Mongo repo" 

dnf install mongodb-mongosh -y
VALIDATE $? "Installed MongoDB client"

INDEX=$(mongosh --host mongodb.daws90s.shop --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -lt 0 ]; then
    mongosh --host mongodb.daws90s.shop </app/db/master-data.js   # we need to check connection manually wheather connection is happend or not
    VALIDATE $? "Load Products"
else
    echo  "Products already loaded ...  SKIPPING"
fi

systemctl enable catalogue 
systemctl restart catalogue 
VALIDATE $? "Restarting catalogue"