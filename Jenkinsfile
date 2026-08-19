pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t munjo-portfolio:${BUILD_NUMBER} .'
            }
        }

        stage('Test') {
            steps {
                sh 'chmod +x test.sh'
                sh './test.sh'
            }
        }

    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed!'
        }
    }
}
