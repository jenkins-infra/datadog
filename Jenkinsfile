#!/usr/bin/env groovy

pipeline {
  agent {
    kubernetes {
      yamlFile 'ci-pod-template.yml'
      defaultContainer('terraform')
    }
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timeout(time: 1, unit: 'HOURS')
    timestamps()
  }

  environment {
    TF_VAR_datadog_api_key          = credentials('jenkins-prod-dd-api-key')
    TF_VAR_datadog_app_key          = credentials('jenkins-prod-dd-app-key')
    TF_BACKEND_CONTAINER_NAME       = 'tfstatedatadog'
    TF_BACKEND_CONTAINER_FILE       = 'master-terraform.tfstate' // Keep master
    TF_BACKEND_STORAGE_ACCOUNT_NAME = 'prodtfstatedatadog'
    TF_BACKEND_STORAGE_ACCOUNT_KEY  = credentials('datadog-storage-account-key')
    TF_INPUT                        = false
    TF_IN_AUTOMATION                = true
    PLAN                            = 'terraform-plan.out'
  }

  stages {
    stage('Plan') {
      steps {
        sh '''
        make init
        make plan
        '''
        stash name: 'terraform-plan', includes: env.PLAN
      }
    }
    stage('Apply') {
      when {
        branch 'main'
      }
      steps {
        unstash 'terraform-plan'
        sh '''
        make init
        make apply
        '''
      }
    }
  }
}
