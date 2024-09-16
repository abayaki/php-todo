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

        stage('Docker Compose Up (PHP-todo)') {
            steps {
                script {
                    bat """
                        docker-compose -f docker-compose.yml up -d
                    """
                }
            }
        }

        stage('Docker Compose Up (Tooling)') {
            steps {
                script {
                    bat """
                        docker-compose -f tooling.yaml up -d
                    """
                }
            }
        }

        stage('Test HTTP Endpoint (PHP-todo)') {
            steps {
                script {
                    // Corrected curl command with complete URL
                    def response = bat(script: "curl -o /dev/null -s -w \"%{http_code}\" http://localhost:8081", returnStdout: true).trim()
                    echo "PHP-todo Response code: ${response}"
                    if (response != '200') {
                        error("PHP-todo HTTP Test failed with status code: ${response}")
                    }
                }
            }
        }

        stage('Test HTTP Endpoint (Tooling)') {
            steps {
                script {
                    // Assuming Tooling app runs on port 5000
                    def response = bat(script: "curl -o /dev/null -s -w \"%{http_code}\" http://localhost:5000", returnStdout: true).trim()
                    echo "Tooling Response code: ${response}"
                    if (response != '200') {
                        error("Tooling HTTP Test failed with status code: ${response}")
                    }
                }
            }
        }

        stage('Docker Login') {
            steps {
                script {
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
                // Clean up all Docker Compose environments and remove images
                bat 'docker-compose -f docker-compose.yml down || exit 0'
                bat 'docker-compose -f tooling.yaml down || exit 0'
                bat 'docker rmi %DOCKERHUB_REPO%:%BRANCH_NAME%-%BUILD_NUMBER% || exit 0'
            }
        }
    }
}
