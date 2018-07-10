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

echo Starting ssh service...
service ssh start

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

# If a custom initialization script is defined, run it and exit.
if [ -n "$APPSETTING_INIT_SCRIPT" ]
then
    echo Running custom initialization script "$APPSETTING_INIT_SCRIPT"
    source $APPSETTING_INIT_SCRIPT
    echo Finished running custom initialization script. Exiting.
    exit
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
    java -Djava.security.egd=file:/dev/./urandom -jar /home/site/wwwroot/default.jar
else
    echo Launching app.jar
    java $JAVA_OPTS -jar /home/site/wwwroot/app.jar
fi

