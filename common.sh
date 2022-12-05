STAT() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32mSUCCESS\e[0m"
  else
    echo -e "\e[31mFAILURE\e[0m"
    echo Check the error in $LOG file
    exit
  fi
}

PRINT() {
  echo " --------------------  $1 ----------------------" >>${LOG}
  echo -e "\e[33m$1\e[0m"
}

LOG=/tmp/$COMPONENT.log
rm -f $LOG

NODEJS() {
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
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>$LOG
  STAT $?

  PRINT "Remove Previous Version of App"
  cd /home/roboshop &>>$LOG
  rm -rf ${COMPONENT} &>>$LOG

  PRINT "Extracting App Content"
  unzip -o /tmp/${COMPONENT}.zip &>>$LOG
  STAT $?

  mv ${COMPONENT}-main ${COMPONENT}
  cd ${COMPONENT}

  PRINT "Install NodeJS Dependencies for App"
  npm install &>>$LOG
  STAT $?

  PRINT "Configure Endpoints for SystemD Configuration"
  sed -i -e 's/REDIS_ENDPOINT/redis.devopsb53.online/' -e 's/CATALOGUE_ENDPOINT/catalogue.devopsb53.online/' /home/roboshop/${COMPONENT}/systemd.service &>>$LOG
  STAT $?

  PRINT "Reload SystemD"
  systemctl daemon-reload &>>$LOG
  STAT $?

  PRINT "Restart Cart"
  systemctl restart ${COMPONENT} &>>$LOG
  STAT $?

  PRINT "Enable Cart Service"
  systemctl enable ${COMPONENT} &>>$LOG
  STAT $?
}