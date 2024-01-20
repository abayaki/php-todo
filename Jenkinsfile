pipeline {
    agent any

    stages {
        stage("Initial cleanup") {
            steps {
                dir("${WORKSPACE}") {
                    deleteDir()
                }
            }
        }

        stage('Checkout SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/darey-devops/php-todo.git'
            }
        }

        stage('Execute Unit Tests') {
            steps {
                sh './vendor/bin/phpunit'
            }
        }

        stage('Prepare Dependencies') {
            steps {
                sh 'mv .env.sample .env'
                sh 'composer install'
                sh 'php artisan migrate'
                sh 'php artisan db:seed'
                sh 'php artisan key:generate'
            }
        }

        stage('Code Analysis') {
            steps {
                sh 'phploc app/ --log-csv build/logs/phploc.csv'
            }
        }
        
        stage('Package Artifact') {
            steps {
                sh 'zip -qr php-todo.zip ${WORKSPACE}/*'
            }
        }

        stage('Upload Artifact to Artifactory') {
            steps {
                script {
                    def server = Artifactory.server 'artifactory-server'
                    def uploadSpec = """{
                        "files": [
                            {
                                "pattern": "php-todo.zip",
                                "target": "generic-local/php-todo", // Replace with your actual repository path
                                "props": "type=zip;status=ready"
                            }
                        ]
                    }"""

                    server.upload spec: uploadSpec
                }
            }
        }

        stage('Deploy to Dev Environment') {
            steps {
                build job: 'ansible-project/main', parameters: [[$class: 'StringParameterValue', name: 'env', value: 'dev']], propagate: false, wait: true
            }
        }

        stage('SonarQube Analysis') {
            environment {
                scannerHome = tool 'SonarQubeScanner'
            }
            steps {
                script {
                    withSonarQubeEnv('sonarqube') {
                        def scannerCmd = "${scannerHome}/bin/sonar-scanner"
                        if (isUnix()) {
                            sh scannerCmd
                        } else {
                            bat scannerCmd
                        }
                    }
                }
            }
        }

        stage('SonarQube Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate()
                }
            }
        }

        // Additional stages...
    }

    post {
        always {
            // Clean up, notification, or other post-build tasks
        }
    }
}
