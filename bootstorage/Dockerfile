# Build stage - compile the application
# Using jammy (Ubuntu 22.04) for multi-arch support (amd64 + arm64)
FROM eclipse-temurin:11-jdk-jammy AS builder

WORKDIR /build

# Copy Maven wrapper and pom.xml first (for better caching)
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Download dependencies (cached unless pom.xml changes)
RUN ./mvnw dependency:go-offline -B

# Copy source code and build
COPY src src
RUN ./mvnw package -DskipTests -B

# Runtime stage - smaller image with just JRE
# Using jammy for multi-arch support (amd64 + arm64)
FROM eclipse-temurin:11-jre-jammy

WORKDIR /usr/spring/bootstorage

COPY --from=builder /build/target/bootstorage-0.0.1-SNAPSHOT.jar /usr/spring/bootstorage/

EXPOSE 5000

CMD ["java", "-jar", "bootstorage-0.0.1-SNAPSHOT.jar"]
