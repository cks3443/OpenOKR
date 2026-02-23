FROM maven:3.9.6-openjdk-8 AS build
WORKDIR /workspace
COPY . .
RUN mvn -pl okr-m-web -am -DskipTests package

FROM openjdk:8-jre
WORKDIR /app
COPY --from=build /workspace/okr-m-web/target/okr-m-web.jar /app/okr-m-web.jar

ENV JAVA_OPTS="-XX:MaxPermSize=256m -Xms128m -Xmx512m"
EXPOSE 8893
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -XX:OnOutOfMemoryError=\"kill -9 %p\" -jar /app/okr-m-web.jar"]