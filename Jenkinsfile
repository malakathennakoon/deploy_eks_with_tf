#!/usr/bin/env groovy

@Library('jenkins-shared-library') _
def gv


pipeline {
    agent any
    tools{
        // define maven tool with name 'maven' in Jenkins global tools configuration
        maven 'maven-3.9'
    }
    parameters {
        string(name: 'image_name', defaultValue: 'shiranatdocker/demo-app:jma', description: 'Image name')
        string(name: 'version', defaultValue: '1.0', description: 'Image version')
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
                    buildJar()
                }
            }
        }
        stage('build image') {
            steps {
                script {
                   buildImage(params.image_name, params.version)
                   pushImage(params.image_name, params.version)
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