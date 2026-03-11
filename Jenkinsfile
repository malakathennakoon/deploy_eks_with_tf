def gv
pipeline {
    agent any
    tools{
        // define maven tool with name 'maven' in Jenkins global tools configuration
        maven 'maven-3.9'
    }

    stages {
        // stage('Init') {
        //     script {
        //         gv = load 'script.groovy'
        //     }
        // }

        stage('Build jar') {
            steps {
                sh 'echo "Building the application..."'
                sh 'mvn package'
            }
        }
        stage('build image') {

            steps {
                echo 'echo "Building the Docker image..."'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh 'echo "Logging in to Docker Hub..."'
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh 'docker build -t shiranatdocker/demo-app:jma-1.0 .'
                    sh 'docker push shiranatdocker/demo-app:jma-1.0'
                } 
            }

        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                sh 'echo "Deploying the application..."'
            }
        }
    }
}