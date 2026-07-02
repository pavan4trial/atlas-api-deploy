# Stage 1: Build
FROM eclipse-temurin:21-jdk-jammy AS builder

# Install git and other build dependencies
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Pass token during build (safer than hardcoding)
ARG GIT_TOKEN=2aa77817bb9b0c20d3b10d1866532648d1071594
ARG REPO_URL=gitea.simpawebtec.in/pavan.s/atlas-api
ARG GIT_DEPLOY_BRANCH=feature-task-development

WORKDIR /app

# Clone the repo
RUN git clone --branch ${GIT_DEPLOY_BRANCH} --single-branch https://oauth2:${GIT_TOKEN}@${REPO_URL} source

WORKDIR /app/source

# Build using the global 'mvn' command instead of './mvnw'
RUN ./mvnw dependency:go-offline
RUN ./mvnw clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:21-jre-jammy
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
# Copy the built jar file
COPY --from=builder /app/source/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]