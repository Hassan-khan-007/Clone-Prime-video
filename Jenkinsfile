pipeline {
    agent any
    
    tools {
        nodejs 'NodeJS'
    }
    
    environment {
        IMAGE_NAME = 'hassankhan786/prime-video-clone'
        DOCKER_CREDENTIALS_ID = 'dockerhub'
        CD_REPO_URL = 'https://github.com/Hassan-khan-007/Clone-Prime-video-CD.git'
        GIT_CREDENTIALS_ID = 'github-credentials'
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
                dependencyCheck additionalArguments: '-n --scan . --disableAssembly', odcInstallation: 'OWASP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build --load -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    """
                }
            }
        }
        
        stage('Trivy Image Scan') {
            steps {
                script {
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
                            echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                        """
                        
                        retry(3) {
                            sh """
                                docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                            """
                        }
                    }
                }
            }
        }

        stage('Update GitOps CD Repository') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${GIT_CREDENTIALS_ID}", 
                                                      usernameVariable: 'GIT_USER', 
                                                      passwordVariable: 'GIT_TOKEN')]) {
                        sh """
                            git config --global user.name "Hassan Khan"
                            git config --global user.email "hassanakhan79@gmail.com"

                            git clone ${https://github.com/Hassan-khan-007/Clone-Prime-video-CD.git} cd-repo

                            cd cd-repo

                            sed -i 's|image:.*|image: ${IMAGE_NAME}:${BUILD_NUMBER}|g' manifests/deployment.yaml

                            git add .
                            git commit -m "CI: Update image tag to build-${BUILD_NUMBER} [skip ci]"
                            git push https://${GIT_TOKEN}@github.com/Hassan-khan-007/Clone-Prime-video-CD.git main
                        """
                    }
                }
            }
        }
    }
}
