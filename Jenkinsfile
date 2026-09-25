pipeline {
    agent any

    environment {
        DOCKERHUB_CREDS = credentials('dockerhub-creds')
        BUILD_TAG_NUM   = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Branch: ${env.BRANCH_NAME}"
                checkout scm
            }
        }

        stage('Make Scripts Executable') {
            steps {
                sh 'chmod +x build.sh deploy.sh'
            }
        }

        stage('Docker Hub Login') {
            steps {
                sh 'echo "$DOCKERHUB_CREDS_PSW" | sudo docker login -u "$DOCKERHUB_CREDS_USR" --password-stdin'
            }
        }

        stage('Build Image') {
            steps {
                sh './build.sh ${BRANCH_NAME} ${BUILD_TAG_NUM}'
            }
        }

        stage('Push & Deploy') {
            steps {
                sh './deploy.sh ${BRANCH_NAME} ${BUILD_TAG_NUM}'
            }
        }

        stage('Verify') {
            steps {
                sh 'curl -sf http://localhost:8081 || (echo "App not responding" && exit 1)'
            }
        }
    }

    post {
        always {
            sh 'sudo docker logout || true'
        }
        success {
            echo "✅ Pipeline succeeded on branch ${env.BRANCH_NAME}"
        }
        failure {
            echo "❌ Pipeline failed on branch ${env.BRANCH_NAME}"
        }
    }
}
