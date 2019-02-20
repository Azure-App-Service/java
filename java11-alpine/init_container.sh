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
EOL
cat /etc/motd

echo "Setup openrc ..." && openrc && touch /run/openrc/softlevel
echo Starting ssh service...
rc-service sshd start

# WEBSITE_INSTANCE_ID will be defined uniquely for each worker instance while running in Azure.
# During development it may not be defined, in that case  we set WEBSITE_INSTNACE_ID=dev.
# This value is used by Spring log configuration
if [ -z "$WEBSITE_INSTANCE_ID" ]
then
    export WEBSITE_INSTANCE_ID=dev
fi

# After all env vars are defined, add the ones of interest to ~/.profile
# Adding to ~/.profile makes the env vars available to new login sessions (ssh) of the same user.

# list of variables that will be added to ~/.profile
export_vars=()

# Step 1. Add app settings to ~/.profile
# To check if an environment variable xyz is an app setting, we check if APPSETTING_xyz is defined as an env var
while read -r var
do
    if [ -n "`printenv APPSETTING_$var`" ]
    then
        export_vars+=($var)
    fi
done <<< `printenv | cut -d "=" -f 1 | grep -v ^APPSETTING_`

# Step 2. Add well known environment variables to ~/.profile
well_known_env_vars=( 
    HTTP_LOGGING_ENABLED
    WEBSITE_SITE_NAME
    WEBSITE_ROLE_INSTANCE_ID
    JAVA_OPTS
    JAVA_HOME
    JAVA_VERSION
    WEBSITE_INSTANCE_ID
    _JAVA_OPTIONS
    CLASSPATH
    )
for var in "${well_known_env_vars[@]}"
do
    if [ -n "`printenv $var`" ]
    then
        export_vars+=($var)
    fi
done

# Step 3. Add environment variables with well known prefixes to ~/.profile
while read -r var
do
    export_vars+=($var)
done <<< `printenv | cut -d "=" -f 1 | grep -E "^(WEBSITE|APPSETTING|SQLCONNSTR|MYSQLCONNSTR|SQLAZURECONNSTR|CUSTOMCONNSTR)_"`

# Write the variables to be exported to ~/.profile
for export_var in "${export_vars[@]}"
do
    echo Exporting env var $export_var
    # We use single quotes to preserve escape characters
	echo export $export_var=\'`printenv $export_var`\' >> ~/.profile
done

# If a Start Up file is specified (in the Application Settings blade), it will be passed as an argument.
if [ ! -z "$1" ]
then
    echo Running Startup File "$1"
    source $1
    startupFileExitCode=$?
    echo Startup File exited with code $startupFileExitCode
    exit $initScriptExitCode
fi

# ***Soon to be DEPERECATED in favor of Start Up file above
# If a custom initialization script is defined, run it and exit.
# ***
if [ -n "$APPSETTING_INIT_SCRIPT" ]
then
    echo Running custom initialization script "$APPSETTING_INIT_SCRIPT"
    source $APPSETTING_INIT_SCRIPT
    initScriptExitCode=$?
    echo Initialization script exited with code $initScriptExitCode
    exit $initScriptExitCode
fi

if [ ! -d /home/site/wwwroot ]
then
    mkdir -p /home/site/wwwroot
fi

# check if app.jar is present and launch it. Otherwise, launch default.jar
if [ ! -f /home/site/wwwroot/app.jar ]
then
    echo Launching default.jar    
    cp /tmp/webapps/default.jar /home/site/wwwroot/default.jar
    java -jar /home/site/wwwroot/default.jar
else
    # If the WEBSITE_LOCAL_CACHE_OPTION application setting is set to Always, copy the jar from the 
    # remote storage to a local folder
    if [ "$APPSETTING_WEBSITE_LOCAL_CACHE_OPTION" = "Always" ]
    then               
        mkdir -p /localcache/site/wwwroot
        cp /home/site/wwwroot/app.jar /localcache/site/wwwroot/app.jar
        JAR_PATH=/localcache/site/wwwroot/app.jar
    else
        JAR_PATH=/home/site/wwwroot/app.jar
    fi
    echo Launching "$JAR_PATH" using JAVA_OPTS="$JAVA_OPTS"
    java $JAVA_OPTS -jar "$JAR_PATH"
fi

