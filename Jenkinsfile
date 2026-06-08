pipeline {
    agent any
    tools {
        maven 'Maven3' 
    }
    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com'
            }
        }
        
        stage('Compile & Test') {
            steps {
                sh 'mvn clean test'
            }
        }
        
        stage('Trivy File System Scan') {
            steps {
                sh 'trivy fs . --severity HIGH,CRITICAL --format table'
            }
        }
        
        stage('SonarCloud Analysis') {
            steps {
                withSonarQubeEnv('SonarCloud') { 
                    sh '''
                        mvn sonar:sonar \
                        -Dsonar.organization=tejaravutla287 \
                        -Dsonar.projectKey=tejaravutla287_devsecops-color-app \
                        -Dsonar.host.url=https://sonarcloud.io
                    '''
                }
            }
        }
        
        stage('Publish to Nexus') {
            steps {
                sh 'mvn deploy -DaltDeploymentRepository=nexus::default::http://localhost:8081/repository/maven-releases/'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t your-dockerhub-user/color-app:${BUILD_NUMBER} .'
            }
        }
        
        stage('Trivy Docker Image Scan') {
            steps {
                sh 'trivy image your-dockerhub-user/color-app:${BUILD_NUMBER} --severity HIGH,CRITICAL'
            }
        }
        
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh 'docker push your-dockerhub-user/color-app:${BUILD_NUMBER}'
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f deployment.yaml'
                sh "kubectl set image deployment/color-app-deploy color-app=your-dockerhub-user/color-app:${BUILD_NUMBER}"
            }
        }
        
        stage('KubeAudit Manifest Scan') {
            steps {
                sh 'kubeaudit all -f deployment.yaml || true'
            }
        }
    }
}
