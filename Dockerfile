FROM openjdk:17-jdk-alpine
COPY mvn-app/target/myapp-1.0.jar /app/myapp.jar
ENTRYPOINT ["java", "-jar", "/app/myapp.jar"]
