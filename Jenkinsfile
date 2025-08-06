pipeline {
    agent any

    environment {
        SONARQUBE = 'MySonar'
        SONARQUBE_PROJECT_KEY = 'my-java-app'
        NEXUS_CREDS = credentials('nexus-creds')
        NEXUS_URL = '3.111.214.26:30002'          // removed http:// here for docker login
        NEXUS_REPO = 'maven-releases'
        DOCKER_IMAGE = "3.111.214.26:30002/myapp:1.0-${env.BUILD_ID}"
    }

    tools {
        maven 'Maven 3'
        jdk 'JDK 17'
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'ganesh.developer', url: 'https://github.com/ganeshsp2296/my-ci-cd-project.git'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv("${SONARQUBE}") {
                    dir('mvn-app') {
                        sh "mvn clean verify sonar:sonar -Dsonar.projectKey=${SONARQUBE_PROJECT_KEY}"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Artifact') {
            steps {
                dir('mvn-app') {
                    sh 'mvn clean package -DskipTests'
                    sh 'ls -l target/'  // Confirm artifact presence
                }
            }
        }

        stage('Upload to Nexus') {
            steps {
                dir('mvn-app') {
                    sh 'ls -l target/'  // Confirm again before upload
                    nexusArtifactUploader artifacts: [[
                        artifactId: 'myapp',
                        classifier: '',
                        file: 'target/myapp-1.0.jar',
                        type: 'jar'
                    ]],
                    credentialsId: 'nexus-creds',
                    groupId: 'com.ganesh',
                    nexusUrl: "${NEXUS_URL}",
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    repository: "${NEXUS_REPO}",
                    version: "1.0-${env.BUILD_ID}"
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                        echo "$PASS" | docker login ${NEXUS_URL} -u "$USER" --password-stdin
                        docker build -t ${DOCKER_IMAGE} .
                        docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }
    }
}
