FROM alpine:3.18

RUN apk add --no-cache wget tar

RUN mkdir /opt/jdk

ENV JAVA_HOME=/opt/jdk
ENV PATH="$JAVA_HOME/bin/:$PATH"

RUN wget https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B9/OpenJDK17U-jdk_x64_alpine-linux_hotspot_17.0.9_9.tar.gz -O jdk.tar.gz && \
    tar -xzf jdk.tar.gz -C $JAVA_HOME --strip-components=1

RUN addgroup -S curlylab && adduser -S curlylab -G curlylab
USER curlylab

WORKDIR /app

COPY build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
