def gv
pipeline {
    agent any
    tools{
        // define maven tool with name 'maven' in Jenkins global tools configuration
        maven 'maven-3.9'
    }

    stages {
        stage('Init') {
            script {
                gv = load 'script.groovy'
            }
         }

        stage('Build jar') {
            script {
                gv.buildJar()
            }
        }
        stage('build image') {
            script {
                gv.buildImage()
            }

        }
        stage('Deploy') {
            script {
                gv.deployApp()
            }
        }
    }
}