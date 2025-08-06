pipeline {
    agent any
    environment {
        SONARQUBE = 'SonarQubeK8s'
        NEXUS_URL = 'http://nexus:8081'
        NEXUS_REPO = 'maven-releases'
    }
    triggers {
        githubPush()
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'ganesh.developer', url: 'https://github.com/yourname/my-ci-cd-project.git'
            }
        }
        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('SonarQubeK8s') {
                    sh "mvn -f mvn-app/pom.xml clean verify sonar:sonar"
                }
            }
        }
        stage('Build Artifact') {
            steps {
                sh 'mvn -f mvn-app/pom.xml clean package'
            }
        }
        stage('Upload to Nexus') {
            steps {
                nexusArtifactUploader artifacts: [[artifactId: 'myapp',
                                                   classifier: '',
                                                   file: 'mvn-app/target/myapp.jar',
                                                   type: 'jar']],
                                      credentialsId: 'nexus-creds',
                                      groupId: 'com.ganesh',
                                      nexusUrl: "${NEXUS_URL}",
                                      nexusVersion: 'nexus3',
                                      protocol: 'http',
                                      repository: "${NEXUS_REPO}",
                                      version: "1.0-${env.BUILD_ID}"
            }
        }
        stage('Docker Build & Push') {
            steps {
                script {
                    def imageTag = "nexus:8081/repository/docker-releases/myapp:1.0-${env.BUILD_ID}"
                    sh """
                        docker build -t ${imageTag} .
                        docker push ${imageTag}
                    """
                }
            }
        }
    }
}