pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'your_dockerhub_username'
        IMAGE_NAME = 'secure-demo-app'
        IMAGE_TAG = "v${env.BUILD_NUMBER}"
        FULL_IMAGE = "${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        
        DOCKER_CONTENT_TRUST = '1'
    }
    
    stages {
        stage('1. Checkout Code') {
            steps {
                checkout scm
            }
        }
        
        stage('2. Build Local Docker Image') {
            steps {
                script {
                    echo "Building local image: ${FULL_IMAGE}"
                    sh "docker build -t ${FULL_IMAGE} ."
                }
            }
        }
        
        stage('3. Container Security Scan (Trivy)') {
            steps {
                script {
                    echo "Scanning image: ${FULL_IMAGE} with Trivy"
                    sh "trivy image --exit-code 1 --severity CRITICAL --no-progress ${FULL_IMAGE}"
                }
            }
        }
        
        stage('4. Push & Sign Image (DCT)') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "echo \\$DOCKER_PASSWORD | docker login -u \\$DOCKER_USERNAME --password-stdin"
                        
                        echo "Pushing and cryptographically signing image: ${FULL_IMAGE}"
                        sh "docker push ${FULL_IMAGE}"
                        
                        sh "docker logout"
                    }
                }
            }
        }
    }
    
    post {
        always {
            sh "docker rmi ${FULL_IMAGE} || exit 0"
        }
        success {
            echo "Pipeline succeeded! Secure, signed image is available."
        }
        failure {
            echo "Pipeline failed! This might be due to a security vulnerability detected by Trivy."
        }
    }
}
