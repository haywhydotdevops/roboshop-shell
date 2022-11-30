source common.sh

PRINT "Install NodeJS Repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash
STAT $?

PRINT "Install NodeJS"
yum install nodejs -y
STAT $?

PRINT "Adding Application User"
useradd roboshop
STAT $?

PRINT "DOWNLOAD App Content"
curl -s -L -o /tmp/cart.zip "https://github.com/roboshop-devops-project/cart/archive/main.zip"
STAT $?

PRINT "Remove Previous Version of App"
cd /home/roboshop
rm -rf cart
STAT $?

PRINT "Extracting App Content"
unzip -o /tmp/cart.zip
STAT $?

mv cart-main cart
cd cart

PRINT "Install NodeJS Dependencies for App"
npm install
STAT $?

PRINT "Configure Endpoints for SystemD Configuration"
sed -i -e 's/REDIS_ENDPOINT/redis.devopsb53.online/' -e 's/CATALOGUE_ENDPOINT/catalogue.devopsb53.online/' /home/roboshop/cart/systemd.service
STAT $?

PRINT "Reload SystemD"
systemctl restart cart
STAT $?

PRINT "Restart Cart"
systemctl restart cart
STAT $?

PRINT "Enable Cart Service"
systemctl enable cart
STAT $?