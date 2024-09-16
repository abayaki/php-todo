pipeline {
    agent any

    environment {
        REGISTRY = 'docker.io'
        REGISTRY_CREDENTIALS = 'dockerhub-credentials'
        DOCKERHUB_REPO = 'abayaki/php-todo-app'  // Updated to use the correct repository
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/abayaki/tooling.git'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    // Build the Docker image
                    def imageTag = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
                    bat """
                        docker build -t ${DOCKERHUB_REPO}:${imageTag} .
                    """
                }
            }
        }

        stage('Docker Compose Up (Tooling)') {
            steps {
                script {
                    // Bring up the tooling app using docker-compose
                    bat """
                        docker-compose -f tooling.yaml up -d
                    """
                }
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    // Login to DockerHub using Jenkins credentials
                    withCredentials([usernamePassword(credentialsId: "${REGISTRY_CREDENTIALS}", usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                        bat """
                            docker login -u %DOCKERHUB_USERNAME% -p %DOCKERHUB_PASSWORD%
                        """
                    }
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    // Push the Docker image to the correct repository
                    def imageTag = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
                    bat """
                        docker push ${DOCKERHUB_REPO}:${imageTag}
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                // Clean up the Docker Compose environment and remove images
                bat 'docker-compose -f tooling.yaml down || exit 0'
                bat 'docker rmi %DOCKERHUB_REPO%:%BRANCH_NAME%-%BUILD_NUMBER% || exit 0'
            }
        }
    }
}
