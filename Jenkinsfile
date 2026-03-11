def gv
pipeline {
    agent any
    tools{
        // define maven tool with name 'maven' in Jenkins global tools configuration
        maven 'maven-3.9'
    }

    stages {
        stage('Init') {
            steps {
                script {
                    gv = load 'script.groovy'
                }
            }
         }

        stage('Build jar') {
            steps {
                script {
                    gv.buildJar()
                }
            }
        }
        stage('build image') {
            steps {
                script {
                    gv.buildImage()
                }
            }

        }
        stage('Deploy') {
            steps {
                script {
                    gv.deployApp()
                }
            }
        }
    }
}