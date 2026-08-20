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

            sh '''
                curl -X POST \
                -H 'Content-type: application/json' \
                --data '{"text":"Jenkins SUCCESS: ${JOB_NAME} #${BUILD_NUMBER}"}' \
                'https://hooks.slack.com/services/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'
            '''
        }

        failure {
            echo 'Pipeline failed!'

            sh '''
                curl -X POST \
                -H 'Content-type: application/json' \
                --data '{"text":"Jenkins FAILED: ${JOB_NAME} #${BUILD_NUMBER}"}' \
                'https://hooks.slack.com/services/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'
            '''
        }
    }
}
