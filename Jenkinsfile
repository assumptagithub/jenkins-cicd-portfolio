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
            slackSend(
                channel: '#jenkins-ci-cd',
                color: 'good',
                message: "Jenkins SUCCESS: ${JOB_NAME} #${BUILD_NUMBER}"
            )
        }

        failure {
            slackSend(
                channel: '#jenkins-ci-cd',
                color: 'danger',
                message: "Jenkins FAILED: ${JOB_NAME} #${BUILD_NUMBER}"
            )
        }
    }
}
