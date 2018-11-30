#!/usr/bin/env groovy

pipeline {

    agent none

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
      TF_BACKEND_STORAGE_ACCOUNT_KEY  = credentials('datadog_state_account_key')
    }

    stages {
        stage('Plan') {
            agent { label 'docker' }
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
            agent { label 'docker' }
            steps {
                sh 'make init'
                unstash 'terraform-plan'
                sh 'make apply'
            }
        }
    }
    post {
      cleanup {
        stage('Clean') {
          when {
            not {
              branch 'master'
            }
          }
          steps {
              sh 'make init'
              sh 'make destroy'
          }
        }
      }
    }
}
