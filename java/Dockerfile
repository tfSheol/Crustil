FROM openjdk:11.0-jre

MAINTAINER Teddy Fontaine Sheol version: 1.0

RUN apt-get update && apt-get install jq curl -y

ENV VERTICLE_HOME="/opt/verticles"

COPY cluster-config.xml $VERTICLE_HOME/cluster-config.xml
COPY entrypoint.sh $VERTICLE_HOME/entrypoint.sh
