#!/usr/bin/env groovy

pipeline {
  agent { label 'docker&&linux' }

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
    // Only on non master branch, "Test Full Apply" ensures that we can always configure everything from scratch
    stage('Test: Apply From Zero') {
      when {
        not {
          branch 'master'
        }
      }
      steps {
        tfsh {
            sh 'make init'
            sh 'make destroy'
            sh 'make plan'
            sh 'make apply'
            sh 'make destroy'
        }
      }
    }
    // Only on non master branch, "Test Apply from Master" prepare the environment from the master branch in order to test the upgrade procedure
    stage('Test: Apply from Master') {
      when {
        not {
          branch 'master'
        }
      }
      steps {
        tfsh {
            git 'https://github.com/jenkins-infra/jenkins-infra-monitoring.git'
            sh 'make init'
            sh 'make plan'
            sh 'make apply'
        }
      }
    }

    stage('Plan apply') {
      steps {
        tfsh {
            sh 'make init'
            sh 'make plan'
            stash name: 'terraform-plan', includes: 'terraform-plan.out'
        }
      }
    }
    stage('Apply') {
      steps {
        tfsh {
            sh 'make init'
            unstash 'terraform-plan'
            sh 'make apply'
        }
      }
    }
  }
}

/**
 * tfsh is a simple function which will wrap whatever block is passed in with
 * the appropriate credentials loaded into the environment for invoking Terraform
 */
Object tfsh(Closure body) {
    body.resolveStrategy = Closure.DELEGATE_FIRST

    def apiKey = "jenkins-staging-dd-api-key"
    def appKey = "jenkins-staging-dd-app-key"
    if (env.BRANCH_NAME == 'master') {
      apiKey = "jenkins-prod-dd-api-key"
      appKey = "jenkins-prod-dd-app-key"
    }

    withCredentials([
        string(credentialsId: apiKey, variable: 'TF_VAR_datadog_api_key'),
        string(credentialsId: appKey, variable: 'TF_VAR_datadog_app_key'),
        ]) {
        ansiColor('xterm') {
            body.call()
        }
    }
}
