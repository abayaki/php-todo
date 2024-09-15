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
                // Check that Dockerfile is present
                bat 'dir'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    def imageTag = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"

                    // Specify the correct path if Dockerfile is in a subdirectory
                    bat """
                        docker build -t ${DOCKERHUB_REPO}:${imageTag} -f build/Dockerfile .
                    """
                }
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    bat """
                        echo %DOCKERHUB_PASSWORD% | docker login -u %DOCKERHUB_USERNAME% --password-stdin
                    """
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
