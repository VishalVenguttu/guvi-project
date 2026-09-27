pipeline {
    agent any

    environment {
        DOCKERHUB_CREDS = credentials('dockerhub-creds')
        BUILD_TAG_NUM   = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
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
                sh 'echo "$DOCKERHUB_CREDS_PSW" | docker login -u "$DOCKERHUB_CREDS_USR" --password-stdin'
            }
        }

        stage('Build & Push') {
            steps {
                script {
                    def repo = (env.BRANCH_NAME == 'master') ? 'prod' : 'dev'
                    sh "./build.sh ${repo} ${BUILD_TAG_NUM}"
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    def repo = (env.BRANCH_NAME == 'master') ? 'prod' : 'dev'
                    sh "./deploy.sh ${repo} ${BUILD_TAG_NUM}"
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
        success {
            echo "Pipeline succeeded on ${env.BRANCH_NAME}"
        }
        failure {
            echo "Pipeline failed on ${env.BRANCH_NAME}"
        }
    }
}
// trigger test
