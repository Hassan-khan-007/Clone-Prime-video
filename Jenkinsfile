pipeline {
    agent any
    
    tools {
        nodejs 'NodeJS'
    }
    
    environment {
        IMAGE_NAME = 'hassankhan786/prime-video-clone'
        DOCKER_CREDENTIALS_ID = 'dockerhub'
    }
    
    stages {
        stage('Checkout Code & Clean') {
            steps {
                cleanWs()
                checkout scm
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'Sonar'
                    
                    withSonarQubeEnv('Sonar') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=my-project \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=http://172.29.144.1:9000
                        """
                    }
                }
            }
        }
        
        stage('Quality Gate Check') {
            steps {
                script {
                    timeout(time: 5, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
            
                        if (qg.status != 'OK') {
                            error "Pipeline aborted because Quality Gate failed: ${qg.status}"
                        } else {
                            echo "Quality Gate passed successfully!"
                        }
                    }
                }
            }
        }
        
        stage('OWASP Security Scan') {
            steps {
                // -n flag use karne se yeh local database ka use karega aur naya download nahi karega
                dependencyCheck additionalArguments: '-n --scan . --disableAssembly', odcInstallation: 'OWASP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        # Build and explicitly load the image into local docker daemon using Buildx
                        docker build --load -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    """
                }
            }
        }
        
        stage('Trivy Image Scan') {
            steps {
                script {
                    // Added --dns=8.8.8.8 so container can resolve network and download DB successfully
                    sh """
                        docker run --rm --dns=8.8.8.8 -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --exit-code 0 --severity HIGH,CRITICAL ${IMAGE_NAME}:${BUILD_NUMBER}
                    """
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", 
                                                usernameVariable: 'DOCKER_USER', 
                                                passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            # Login to Docker Hub securely
                            echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                        """
                        
                        // Retry block to handle network timeout safely during push
                        retry(3) {
                            sh """
                                docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                            """
                        }
                    }
                }
            }
        }
    }
}
