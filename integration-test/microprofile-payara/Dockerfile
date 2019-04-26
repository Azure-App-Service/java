FROM appsvc/java:8-jre8_0000000000

ENV payaramicro_port $PORT

COPY target/${project.build.finalName}-microbundle.jar /home/site/wwwroot/app.jar

# ENTRYPOINT java -jar /home/site/wwwroot/app.jar
