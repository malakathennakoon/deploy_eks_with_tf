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
                   dockerLogin()
                   buildImage(params.image_name, params.version)
                   pushImage(params.image_name, params.version)
                }
            }

        }
        stage('Terraform Apply') {
            steps {
                withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'jenkins-credentials'
                ]]) {
                sh '''
                terraform init
                terraform apply -auto-approve
                '''
                }
            }
        }

        stage('Get Terraform Outputs') {
            steps {
                script {
                env.CLUSTER_NAME = sh(
                    script: "terraform output -raw cluster_name",
                    returnStdout: true
                ).trim()

                env.AWS_REGION = sh(
                    script: "terraform output -raw cluster_region",
                    returnStdout: true
                ).trim()
                }
            }
        }
        stage('Wait for EKS Cluster') {
            steps {
                withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'jenkins-credentials'
                ]]) {

                sh '''
                aws eks wait cluster-active \
                    --name $CLUSTER_NAME \
                    --region $AWS_REGION
                '''

                }
            }
        }

        stage('Configure kubeconfig') {
            steps {
                withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'jenkins-credentials'
                ]]) {

                sh '''
                aws eks update-kubeconfig \
                    --name $CLUSTER_NAME \
                    --region $AWS_REGION

                kubectl get nodes
                '''
                }
            }
        }

        stage('Deploy Microservices') {
            steps {
                sh '''
                kubectl apply -f manifests/
                '''
            }
        }
    }
}