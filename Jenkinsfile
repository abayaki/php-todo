pipeline {
    agent any

    stages {
        stage("Initial Cleanup") {
            steps {
                cleanWs()
            }
        }

        stage('Checkout SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/abayaki/php-todo.git'
            }
        }

        stage('Prepare Dependencies') {
            steps {
                script {
                    // Create a local PHP configuration file in the project directory
                    sh 'echo "extension=mbstring.so" > mbstring.ini'

                    // Install the mbstring extension without sudo
                    sh 'apt-get update && apt-get install -y php7.4-mbstring'

                    sh 'mv .env.sample .env'
                    sh 'composer install'
                    sh 'php artisan migrate'
                    sh 'php artisan db:seed'
                    sh 'php artisan key:generate'
                }
            }
        }

        stage('Execute Unit Tests') {
            steps {
                sh './vendor/bin/phpunit'
            }
        }

        stage('Code Analysis') {
            steps {
                sh 'phploc app/ --log-csv build/logs/phploc.csv'
            }
        }

        stage('SonarQube Quality Gate') {
            when {
                branch pattern: "^develop.*|^hotfix.*|^release.*|^main.*", comparator: "REGEXP"
            }
            environment {
                scannerHome = tool 'SonarQubeScanner'
            }
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh "${scannerHome}/bin/sonar-scanner -Dproject.settings=sonar-project.properties"
                }
                timeout(time: 1, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
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
                build job: 'ansible-project/main', parameters: [string(name: 'env', value: 'dev')], propagate: false, wait: true
            }
        }
    }
}
