COMPONENT=cart
source common.sh

PRINT "Install NodeJS Repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOG
STAT $?

PRINT "Install NodeJS"
yum install nodejs -y &>>$LOG
STAT $?

PRINT "Adding Application User"
id roboshop &>>$LOG
if [ $? -ne 0 ]; then
  useradd roboshop &>>$LOG
fi
STAT $?

PRINT "DOWNLOAD App Content"
curl -s -L -o /tmp/cart.zip "https://github.com/roboshop-devops-project/cart/archive/main.zip" &>>$LOG
STAT $?

PRINT "Remove Previous Version of App"
cd /home/roboshop &>>$LOG
rm -rf cart
STAT $?

PRINT "Extracting App Content"
unzip -o /tmp/cart.zip &>>$LOG
STAT $?

mv cart-main cart
cd cart

PRINT "Install NodeJS Dependencies for App"
npm install &>>$LOG
STAT $?

PRINT "Configure Endpoints for SystemD Configuration"
sed -i -e 's/REDIS_ENDPOINT/redis.devopsb53.online/' -e 's/CATALOGUE_ENDPOINT/catalogue.devopsb53.online/' /home/roboshop/cart/systemd.service &>>$LOG
STAT $?

PRINT "Reload SystemD"
systemctl daemon-reload &>>$LOG
STAT $?

PRINT "Restart Cart"
systemctl restart cart &>>$LOG
STAT $?

PRINT "Enable Cart Service"
systemctl enable cart &>>$LOG
STAT $?