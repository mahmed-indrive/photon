FROM maven:3.9-eclipse-temurin-21-alpine AS builder

WORKDIR /src

COPY pom.xml .
RUN mvn dependency:go-offline -q

COPY src src
RUN mvn package -DskipTests -q

FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

COPY --from=builder /src/target/photon-1.1.0.jar /app/photon.jar

ENTRYPOINT ["java", "-jar", "/app/photon.jar"]
