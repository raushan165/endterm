pipeline {
    agent any
    
    environment {
        // Replace with your Docker Hub username
        DOCKER_REGISTRY = 'your_dockerhub_username'
        IMAGE_NAME = 'secure-demo-app'
        IMAGE_TAG = "v${env.BUILD_NUMBER}"
        FULL_IMAGE = "${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        
        // SECURITY FEATURE: Enable Docker Content Trust for cryptographic signing
        DOCKER_CONTENT_TRUST = '1'
    }
    
    stages {
        stage('1. Checkout Code') {
            steps {
                // Checkout code from the repository
                checkout scm
            }
        }
        
        stage('2. Build Local Docker Image') {
            steps {
                script {
                    echo "Building local image: ${FULL_IMAGE}"
                    // Build the image but don't push it yet
                    bat "docker build -t ${FULL_IMAGE} ."
                }
            }
        }
        
        stage('3. Container Security Scan (Trivy)') {
            steps {
                script {
                    echo "Scanning image: ${FULL_IMAGE} with Trivy"
                    // SECURITY FEATURE: Scan local image before pushing. 
                    // --exit-code 1 ensures the pipeline fails if CRITICAL vulnerabilities are found.
                    bat "trivy image --exit-code 1 --severity CRITICAL --no-progress ${FULL_IMAGE}"
                }
            }
        }
        
        stage('4. Push & Sign Image (DCT)') {
            steps {
                script {
                    // Requires Docker Hub credentials stored in Jenkins with ID 'docker-hub-credentials'
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        // Login to Docker Hub
                        bat "echo %DOCKER_PASSWORD% | docker login -u %DOCKER_USERNAME% --password-stdin"
                        
                        echo "Pushing and cryptographically signing image: ${FULL_IMAGE}"
                        // Since DOCKER_CONTENT_TRUST=1, this push triggers Docker to sign the image.
                        // (Requires DCT keys to be present/loaded in the Jenkins environment)
                        bat "docker push ${FULL_IMAGE}"
                        
                        // Cleanup credentials
                        bat "docker logout"
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up the local image from the Jenkins worker node
            bat "docker rmi ${FULL_IMAGE} || exit 0"
        }
        success {
            echo "Pipeline succeeded! Secure, signed image is available."
        }
        failure {
            echo "Pipeline failed! This might be due to a security vulnerability detected by Trivy."
        }
    }
}
