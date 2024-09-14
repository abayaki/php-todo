pipeline {
    agent any

    environment {
        REGISTRY = 'docker.io'  // Docker registry
        REGISTRY_CREDENTIALS = 'Docker-credential'  // Jenkins credentials ID for DockerHub
        DOCKERHUB_REPO = 'abayaki/php-todo-app'
    }

    stages {
        stage('Checkout') {
            steps {
                // Check out the source code
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/abayaki/php-todo.git'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    // Set image tag based on the branch
                    def imageTag = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"

                    // Build Docker image
                    sh """
                        docker build -t ${DOCKERHUB_REPO}:${imageTag} .
                    """
                }
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    // Login to DockerHub using Jenkins credentials
                    sh """
                        echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin
                    """
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    def imageTag = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
                    // Push Docker image to DockerHub
                    sh """
                        docker push ${DOCKERHUB_REPO}:${imageTag}
                    """
                }
            }
        }
    }

    post {
        always {
            // Clean up unused Docker images after the build
            sh 'docker rmi ${DOCKERHUB_REPO}:${env.BRANCH_NAME}-${env.BUILD_NUMBER} || true'
        }
    }
}
