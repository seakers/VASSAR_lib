FROM gradle:jdk8 as builder
ARG java_libs=./lib
COPY --chown=gradle:gradle ./src /home/gradle/src
COPY --chown=gradle:gradle $java_libs /home/gradle/lib
COPY --chown=gradle:gradle build.gradle settings.gradle /home/gradle/
WORKDIR /home/gradle/