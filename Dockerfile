# Build the DHIS2 Core server from source
FROM maven:3.5.4-jdk-8-slim as build
#NB - maven-frontend-plugin breaks on Alpine linux

RUN apt-get update && apt-get install -y curl git && rm -rf /var/lib/apt/lists/*
#NB - web-apps build requires that core is built within a git repository, so just copy over the whole tree for now
ADD . /src

RUN cd src/dhis-2 && mvn clean install -DskipTests=true -T1C
RUN cd src/dhis-2/dhis-web && mvn clean install -DskipTests=true -T1C -U

# Serve the packaged .war file
FROM tomcat:8.5.34-jre8-alpine as serve

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /src/dhis-2/dhis-web/dhis-web-portal/target/dhis.war /usr/local/tomcat/webapps/ROOT.war
ENV DHIS2_HOME=/DHIS2_home