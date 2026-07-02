# Stage 1: Build
FROM eclipse-temurin:21-jdk-jammy AS builder

RUN apk update && apk add --no-cache git

# Pass token during build (safer than hardcoding)
ARG GIT_TOKEN=2aa77817bb9b0c20d3b10d1866532648d1071594
ARG REPO_URL=gitea.simpawebtec.in/pavan.s/atlas-api
ARG GIT_DEPLOY_BRANCH=feature-boq-implementation

# Clone the repo
RUN git clone --branch ${GIT_DEPLOY_BRANCH} --single-branch https://oauth2:${GIT_TOKEN}@${REPO_URL} app

WORKDIR /app
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline
COPY src ./src
RUN ./mvnw clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]