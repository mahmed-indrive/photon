FROM maven:3.9-eclipse-temurin-21-alpine AS builder

WORKDIR /src

COPY pom.xml .
RUN mvn dependency:go-offline -q

COPY src src
RUN mvn package -DskipTests -q

FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# Glob avoids re-pinning the version here on every release; shade leaves exactly
# one photon-<version>.jar in target/ (the unshaded one is original-photon-*.jar).
COPY --from=builder /src/target/photon-*.jar /app/photon.jar

ENTRYPOINT ["java", "-jar", "/app/photon.jar"]
