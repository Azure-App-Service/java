# Integration Tests
This folder contains a series of Maven projects that will evaluate if the Docker
image used to deliver Java SE support on Azure App Service works for a different
set of Java web frameworks.

The projects here also provide indication on how to set up the different
frameworks to use the $PORT configuration dynamically injected by App Service.

## Run
To run the tests, make sure that Docker is installed locally, and that the image `appsvc/java:8-jre8_0000000000` exists locally (or latest from Docker Hub will be used).

Then run the following Maven command in the
`integration-test` folder:

        mvn clean verify --fail-at-end

### Results
Once the command above is executed, you should see a similar Maven output, in
case of failure:

```sh
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary:
[INFO] 
[INFO] micronaut-1.x 1.0-SNAPSHOT ......................... FAILURE [  7.368 s]
[INFO] Azure App Service Sample with SparkJava REST API 1.0-SNAPSHOT FAILURE [  3.417 s]
[INFO] springboot-1.x 0.0.1-SNAPSHOT ...................... SUCCESS [ 18.839 s]
[INFO] springboot-2.x 1.0.0-SNAPSHOT ...................... SUCCESS [ 18.342 s]
[INFO] App Service Sample with Quarkus REST API 1.0-SNAPSHOT FAILURE [  5.826 s]
[INFO] App Service with Ratpack REST API 1.0-SNAPSHOT ..... FAILURE [  3.902 s]
[INFO] microprofile 1.0-SNAPSHOT .......................... FAILURE [  8.523 s]
[INFO] microprofile-thorntail 1.0-SNAPSHOT ................ FAILURE [ 15.561 s]
[INFO] Azure App Service Samples Parent 1.0-SNAPSHOT ...... SUCCESS [  0.001 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD FAILURE
[INFO] ------------------------------------------------------------------------
```

## Roadmap / Backlog
This integration-test suite is an initial effort. Ultimately, the tests should
be performed as part of the build and release of the Docker image.

Desired enhancements to this suite of tests are:

1. Use JUnit-based tests to build, run, and validate the containers
1. Adopt TestContainers.org to generate container images on the fly
1. Make tests run as part of the `integration-test` phase on Maven
1. Generate Surefire/Failsafe reports of all modules
1. Test other images (e.g. `java11`)
