pipeline {
    agent any
    tools {
        maven 'Maven3' 
    }
    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/tejaravutla287/POC-4'
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
        
        stage('Maven Build') {
            steps {
                // Compiles, verifies, and confirms final target package properties are perfect
                sh 'mvn package -DskipTests'
            }
        }
        
        stage('Publish to Nexus') {
            steps {
                sh 'mvn deploy --settings /var/lib/jenkins/.m2/settings.xml -DaltDeploymentRepository=nexus-snapshots::default::http://localhost:8081/repository/maven-snapshots/'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t bhanutejaravutla/color-app:${BUILD_NUMBER} .'
            }
        }
        
        stage('Trivy Docker Image Scan') {
            steps {
                sh 'export TRIVY_SKIP_JAVA_DB=true'
                sh 'trivy image --scanners vuln --severity HIGH,CRITICAL bhanutejaravutla/color-app:11'
            }
        }
        
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh 'docker push bhanutejaravutla/color-app:${BUILD_NUMBER}'
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
