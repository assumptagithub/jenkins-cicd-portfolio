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
                sh 'docker build -t munjo185/munjo-portfolio:${BUILD_NUMBER} .'
            }
        }

        stage('Test') {
            steps {
                sh 'chmod +x test.sh'
                sh './test.sh'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        docker push munjo185/munjo-portfolio:${BUILD_NUMBER}
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    export KUBECONFIG=/tmp/minikube-kubeconfig

                    kubectl set image deployment/munjo-portfolio \
                      munjo-portfolio=munjo185/munjo-portfolio:${BUILD_NUMBER}

                    kubectl rollout status deployment/munjo-portfolio --timeout=120s
                '''
            }
        }
    }

    post {
        success {
            slackSend(
                channel: '#jenkins-ci-cd',
                color: 'good',
                message: "Jenkins SUCCESS: ${JOB_NAME} #${BUILD_NUMBER} - Docker image pushed and deployed to Kubernetes"
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
