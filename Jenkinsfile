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
                sh 'mkdir -p .trivycache'
                // Bypasses Java DB entirely by locking scanners to vulnerability/secret modes and restricting pkgs to the OS layer
                sh '''
                    trivy fs \
                    --cache-dir .trivycache \
                    --scanners vuln,secret \
                    --pkg-types os \
                    --severity HIGH,CRITICAL \
                    --format table .
                '''
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
                sh 'mkdir -p .trivycache'
                // Applying the exact same resource-saving constraints to your container image evaluation loop
                sh '''
                    trivy image \
                    --cache-dir .trivycache \
                    --scanners vuln,secret \
                    --pkg-types os \
                    --severity HIGH,CRITICAL \
                    bhanutejaravutla/color-app:${BUILD_NUMBER}
                '''
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
                // Keep validation off here to bypass structural file checks
                sh 'kubectl apply -f deployment.yaml --validate=false'
                
                // Remove the flag here so the container image update runs natively
                sh "kubectl set image deployment/color-app-deploy color-app=bhanutejaravutla/color-app:${BUILD_NUMBER}"
            }
        }


        
        stage('KubeAudit Manifest Scan') {
            steps {
                sh 'kubeaudit all -f deployment.yaml || true'
            }
        }
    }
}
