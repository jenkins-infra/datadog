#!/usr/bin/env groovy

pipeline {

    agent {
      label 'docker'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 1, unit: 'HOURS')
        timestamps()
    }

    environment {
      TF_VAR_datadog_api_key          = "${ env.BRANCH_NAME=='master'?credentials('jenkins-prod-dd-api-key'):credentials('jenkins-staging-dd-api-key')}"
      TF_VAR_datadog_app_key          = "${ env.BRANCH_NAME=='master'?credentials('jenkins-prod-dd-app-key'):credentials('jenkins-staging-dd-app-key')}"
      TF_BACKEND_CONTAINER_NAME       = "tfstatedatadog"
      TF_BACKEND_CONTAINER_FILE       = "${ env.BRANCH_NAME=='master'?'master':'staging'}-terraform.tfstate"
      TF_BACKEND_STORAGE_ACCOUNT_NAME = "prodtfstatedatadog"
      TF_BACKEND_STORAGE_ACCOUNT_KEY  = credentials('datadog-storage-account-key')
    }

    stages {
        stage('Test Configuration From Zero') {
          when {
            not {
              branch 'master'
            }
          }
          steps {
              sh 'make init'
              sh 'make destroy'
              sh 'make plan'
              sh 'make apply'
              sh 'destroy'
          }
        }

        stage('Test Configuration Upgrade') {
          when {
            not {
              branch 'master'
            }
          }
          steps {
             git 'https://github.com/jenkins-infra/jenkins-infra-monitoring.git'
             sh 'make init'
             sh 'make destroy'
             sh 'make plan'
             sh 'make apply'
             checkout scm
             sh 'make plan'
             sh 'make apply'
          }
        }

        stage('Plan') {
            steps {
                sh 'make init'
                sh 'make plan'
                stash name: 'terraform-plan', includes: 'terraform-plan.out'
            }
        }

        stage('Review') {
            when { branch 'master' }
            steps {
                timeout(30) {
                    input message: 'Apply the planned updates to DataDog?', ok: 'Apply'
                }
            }
        }

        stage('Apply') {
            steps {
                sh 'make init'
                unstash 'terraform-plan'
                sh 'make apply'
            }
        }
    }
}
