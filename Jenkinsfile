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

        stage('Docker Compose Up') {
            steps {
                script {
                    bat """
                        docker-compose -f tooling.yaml up -d
                    """
                }
            }
        }

        stage('Test HTTP Endpoint') {
            steps {
                script {
                    def responseHttp = bat(script: 'curl -o /dev/null -s -w "%{http_code}" http://localhost:5000', returnStdout: true).trim()
                    echo "HTTP Response code: ${responseHttp}"
                    if (responseHttp != '200') {
                        error("HTTP Test failed with status code: ${responseHttp}")
                    }
                }
            }
        }

        stage('Test HTTPS Endpoint') {
            steps {
                script {
                    def response = bat(script: "curl -o /dev/null -s -w \"%{http_code}\" http://localhost:5000", returnStdout: true).trim()
                    echo "HTTPS Response code: ${responseHttps}"
                    if (responseHttps != '200') {
                        error("HTTPS Test failed with status code: ${responseHttps}")
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
                bat 'docker-compose -f tooling.yaml down || exit 0'
                bat "docker rmi ${DOCKERHUB_REPO}:${BRANCH_NAME}-${BUILD_NUMBER} || exit 0"
            }
        }
    }
}
