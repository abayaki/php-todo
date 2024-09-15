pipeline {
    agent any

    environment {
        REGISTRY = 'docker.io'
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
                    if (isUnix()) {
                        sh """
                            docker build -t ${DOCKERHUB_REPO}:${imageTag} .
                        """
                    } else {
                        bat """
                            docker build -t ${DOCKERHUB_REPO}:${imageTag} .
                        """
                    }
                }
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                        if (isUnix()) {
                            sh """
                                echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin
                            """
                        } else {
                            bat """
                                echo %DOCKERHUB_PASSWORD% | docker login -u %DOCKERHUB_USERNAME% --password-stdin
                            """
                        }
                    }
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    def imageTag = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"

                    // Push Docker image to DockerHub
                    if (isUnix()) {
                        sh """
                            docker push ${DOCKERHUB_REPO}:${imageTag}
                        """
                    } else {
                        bat """
                            docker push ${DOCKERHUB_REPO}:${imageTag}
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                try {
                    // Clean up unused Docker images after the build
                    if (isUnix()) {
                        sh 'docker rmi ${DOCKERHUB_REPO}:${env.BRANCH_NAME}-${env.BUILD_NUMBER} || true'
                    } else {
                        bat 'docker rmi ${DOCKERHUB_REPO}:${env.BRANCH_NAME}-${env.BUILD_NUMBER} || true'
                    }
                } catch (Exception e) {
                    echo "Failed to remove Docker images: ${e.getMessage()}"
                }
            }
        }
    }
}
