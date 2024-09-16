pipeline {
    agent any

    environment {
        REGISTRY = 'docker.io'
        REGISTRY_CREDENTIALS = 'dockerhub-credentials'
        DOCKERHUB_REPO = 'abayaki/php-todo-app'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/abayaki/php-todo.git'
            }
        }

        stage('Verify Dockerfile') {
            steps {
                bat 'dir'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    def imageTag = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"

                    bat """
                        docker build -t abayaki/php-todo-app:${imageTag} .
                    """
                }
            }
        }

        // Add debug logging for credentials
        stage('Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${REGISTRY_CREDENTIALS}", usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                        echo "logging into DockerHub as ${DOCKERHUB_USERNAME}"
                        bat """
                            docker login -u %DOCKERHUB_USERNAME% --password-stdin <<< %DOCKERHUB_PASSWORD%
                        """
                    }
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
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
            bat 'docker rmi %DOCKERHUB_REPO%:%BRANCH_NAME%-%BUILD_NUMBER% || exit 0'
        }
    }
}
