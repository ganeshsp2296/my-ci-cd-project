FROM openjdk:17-jdk-alpine
COPY mvn-app/target/myapp.jar /app/myapp.jar
ENTRYPOINT ["java", "-jar", "/app/myapp.jar"]