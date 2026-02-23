FROM maven:3.9.6-eclipse-temurin-8 AS build
WORKDIR /workspace
COPY . .
RUN mvn -pl okr-service -am -DskipTests package

FROM eclipse-temurin:8-jre
WORKDIR /app
COPY --from=build /workspace/okr-service/target/okr-service.jar /app/okr-service.jar

ENV JAVA_OPTS="-XX:MaxPermSize=256m -Xms128m -Xmx2g"
EXPOSE 20254
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -XX:OnOutOfMemoryError=\"kill -9 %p\" -jar /app/okr-service.jar --framework.dubbo.protocol.port=20254"]