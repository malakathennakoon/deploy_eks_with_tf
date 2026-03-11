#!/usr/bin/env groovy

def buildJar() {
    sh 'echo "Building the application..."'
    sh 'mvn package'
}

def buildImage() {
    echo "Building the Docker image..."
    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
        sh 'echo "Logging in to Docker Hub..."'
        sh 'echo $PASS | docker login -u $USER --password-stdin'
        sh 'docker build -t shiranatdocker/demo-app:jma-1.0 .'
        sh 'docker push shiranatdocker/demo-app:jma-1.0'
    } 
}

def deployApp() {
    echo "Deploying the application..."
    sh 'echo "Deploying the application..."'
}

return this