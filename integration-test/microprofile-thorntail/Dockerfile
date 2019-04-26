FROM appsvc/java:8-jre8_0000000000

ENV THORNTAIL_HTTP_PORT $PORT

COPY target/${project.build.finalName}-thorntail.jar /home/site/wwwroot/app.jar

# ENTRYPOINT java -Djava.net.preferIPv4Stack=true -jar /home/site/wwwroot/app.jar
