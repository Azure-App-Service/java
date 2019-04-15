#!/usr/bin/env bash

cat >/etc/motd <<EOL 
  _____                               
  /  _  \ __________ _________   ____  
 /  /_\  \\___   /  |  \_  __ \_/ __ \ 
/    |    \/    /|  |  /|  | \/\  ___/ 
\____|__  /_____ \____/ |__|    \___  >
        \/      \/                  \/ 
A P P   S E R V I C E   O N   L I N U X
Documentation: http://aka.ms/webapp-linux

**NOTE**: No files or system changes outside of /home will persist beyond your application's current session. /home is your application's persistent storage and is shared across all the server instances.


EOL
cat /etc/motd

echo "Setup openrc ..." && openrc && touch /run/openrc/softlevel

echo Updating /etc/ssh/sshd_config to use PORT $SSH_PORT
sed -i "s/SSH_PORT/$SSH_PORT/g" /etc/ssh/sshd_config

echo Starting ssh service...
rc-service sshd start

# COMPUTERNAME will be defined uniquely for each worker instance while running in Azure.
# If COMPUTERNAME isn't available, we assume that the container is running in a dev environment.
# If running in dev environment, define required environment variables.
if [ -z "$COMPUTERNAME" ]
then
    export COMPUTERNAME=dev

    # BEGIN: AzMon related environment variables
    export HTTP_LOGGING_ENABLED=1
    export WEBSITE_HOSTNAME=dev.appservice.com
    export APPSETTING_WEBSITE_AZMON_ENABLED=True
    # END: AzMon related environment variables
fi

# Variables in logging.properties aren't being evaluated, so explicitly update logging.properties with the appropriate values
sed -i "s/__PLACEHOLDER_COMPUTERNAME__/$COMPUTERNAME/" /tmp/appservice/logging.properties

# BEGIN: Configure Java / Spring Boot properties
# Precedence order of properties can be found here: https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html

SPRING_BOOT_PROPS=
SPRING_BOOT_PROPS="$SPRING_BOOT_PROPS --server.port=$PORT"
SPRING_BOOT_PROPS="$SPRING_BOOT_PROPS --logging.file=/home/LogFiles/Application/spring.$COMPUTERNAME.log"
# Increase the default size so that Easy Auth headers don't exceed the size limit
SPRING_BOOT_PROPS="$SPRING_BOOT_PROPS --server.max-http-header-size=16384"

echo "Using SPRING_BOOT_PROPS=$SPRING_BOOT_PROPS"

export JAVA_OPTS="$JAVA_OPTS -noverify"
export JAVA_OPTS="$JAVA_OPTS -Djava.util.logging.config.file=/tmp/appservice/logging.properties"
export JAVA_TOOL_OPTIONS="$JAVA_TOOL_OPTIONS -Djava.net.preferIPv4Stack=true"

# END: Configure Java / Spring Boot properties

# BEGIN: Configure /etc/profile

eval $(printenv | sed -n "s/^\([^=]\+\)=\(.*\)$/export \1=\2/p" | sed 's/"/\\\"/g' | sed '/=/s//="/' | sed 's/$/"/' >> /etc/profile)

# We want all ssh sesions to start in the /home directory
echo "cd /home" >> /etc/profile

# END: Configure /etc/profile

# BEGIN: Process startup file / startup command, if any

DEFAULT_STARTUP_FILE=/home/startup.sh
STARTUP_FILE=
STARTUP_COMMAND=

# The web app can be configured to run a custom startup command or a custom startup script
# This custom command / script will be available to us as a param ($1, $2, ...)
#
# IF $1 is a non-empty string AND an existing file, we treat $1 as a startup file (and ignore $2, $3, ...)
# IF $1 is a non-empty string BUT NOT an existing file, we treat $@ (equivalent of $1, $2, ... combined) as a startup command
# IF $1 is an empty string AND $DEFAULT_STARTUP_FILE exists, we use it as the startup file
# ELSE, we skip running the startup script / command
#
if [ -n "$1" ] # $1 is a non-empty string
then
    if [ -f "$1" ] # $1 file exists
    then
        STARTUP_FILE=$1
    else
        STARTUP_COMMAND=$@
    fi
elif [ -f $DEFAULT_STARTUP_FILE ] # Default startup file path exists
then
    STARTUP_FILE=$DEFAULT_STARTUP_FILE
fi

echo STARTUP_FILE=$STARTUP_FILE
echo STARTUP_COMMAND=$STARTUP_COMMAND

# If $STARTUP_FILE is a non-empty string, we need to run the startup file
if [ -n "$STARTUP_FILE" ]
then
    TMP_STARTUP_FILE=/tmp/startup.sh
    echo Copying $STARTUP_FILE to $TMP_STARTUP_FILE
    # Convert EOL to Unix-style
    cat $STARTUP_FILE | tr '\r' '\n' > $TMP_STARTUP_FILE
    echo Running STARTUP_FILE: $TMP_STARTUP_FILE
    source $TMP_STARTUP_FILE
    # Capture the exit code before doing anything else
    EXIT_CODE=$?
    echo Finished running startup file \'$TMP_STARTUP_FILE\'. Exiting with exit code $EXIT_CODE.
    exit $EXIT_CODE
else
    echo No STARTUP_FILE available.
fi

if [ -n "$STARTUP_COMMAND" ]
then
    echo Running STARTUP_COMMAND: "$STARTUP_COMMAND"
    $STARTUP_COMMAND
    # Capture the exit code before doing anything else
    EXIT_CODE=$?
    echo Finished running startup command \'$STARTUP_COMMAND\'. Exiting with exit code $EXIT_CODE.
    exit $EXIT_CODE
else
    echo No STARTUP_COMMAND defined.
fi

# END: Process startup file / startup command, if any

if [ ! -d /home/site/wwwroot ]
then
    mkdir -p /home/site/wwwroot
fi

# check if app.jar is present and launch it. Otherwise, launch the parking page app.
if [ ! -f /home/site/wwwroot/app.jar ]
then
    echo Using the parking page app
    APP_JAR_PATH=/tmp/appservice/default.jar
else
    # If the WEBSITE_LOCAL_CACHE_OPTION application setting is set to Always, copy the jar from the 
    # remote storage to a local folder
    if [ "$APPSETTING_WEBSITE_LOCAL_CACHE_OPTION" = "Always" ]
    then               
        mkdir -p /localcache/site/wwwroot
        cp /home/site/wwwroot/app.jar /localcache/site/wwwroot/app.jar
        APP_JAR_PATH=/localcache/site/wwwroot/app.jar
    else
        APP_JAR_PATH=/home/site/wwwroot/app.jar
    fi
fi

CMD="java -cp $APP_JAR_PATH:/tmp/appservice/azure.appservice.jar $JAVA_OPTS org.springframework.boot.loader.PropertiesLauncher $SPRING_BOOT_PROPS"
echo Running command: "$CMD"
$CMD
