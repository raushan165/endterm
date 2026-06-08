# Secure CI/CD Pipeline Demo

This project provides a practical demonstration of a secure CI/CD pipeline resolving the architectural weaknesses of blindly pushing Docker images. It uses Jenkins, Trivy (for scanning), and Docker Content Trust (for signing).

## Files Included
* **`Jenkinsfile`**: The core CI/CD pipeline logic. Features automatic vulnerability scanning before the push stage, and enables Docker Content Trust to cryptographically sign the image.
* **`Dockerfile`**: A sample Dockerfile following security best practices (e.g., using an alpine base image and a non-root user).
* **`server.js` & `package.json`**: A simple Node.js web application to act as the build payload.

## How the Jenkinsfile works:
1. **Checkout**: Pulls this repository.
2. **Build**: Builds the Docker image locally on the Jenkins node.
3. **Security Scan**: Runs `trivy image --exit-code 1 --severity CRITICAL ...` against the local image. If Trivy finds critical vulnerabilities, the exit code is 1, causing the Jenkins pipeline to **immediately fail and stop**. The image is never pushed to Docker Hub.
4. **Sign & Push**: If the scan passes, Jenkins logs into Docker Hub and pushes the image. The environment variable `DOCKER_CONTENT_TRUST=1` is injected, which forces the Docker engine to cryptographically sign the image using your private keys.

## Setup Instructions

### 1. Prerequisites
You will need a Jenkins server with the following installed:
- Docker Engine
- Trivy CLI (`trivy`)
- Jenkins plugins: Pipeline, Docker Pipeline, Credentials Binding

### 2. Jenkins Credentials
Before running the pipeline, set up your credentials in Jenkins (Manage Jenkins -> Credentials):
- Add a "Username with password" credential.
- Set the ID to `docker-hub-credentials`.
- Enter your Docker Hub username and password/access token.

### 3. Docker Content Trust Keys
For Docker Content Trust to work autonomously in Jenkins, you must generate DCT keys for your registry and load them onto the Jenkins worker node so the Docker CLI can access them during the build.
* Usually, this involves running `docker trust key generate your-name` and providing the private key to the Jenkins environment securely.

### 4. Running the Pipeline
Create a new Jenkins Pipeline job, point it to this Git repository, and run it. You will see the pipeline fail if you modify the Dockerfile to include an old, vulnerable base image (e.g., `node:10`), proving the security gate works!
