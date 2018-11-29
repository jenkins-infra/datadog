#!/usr/bin/env groovy

pipeline {

    agent none

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 1, unit: 'HOURS')
        timestamps()
    }

    stages {
        stage('Init') {
          agent { label 'docker' }
          steps {
            tfsh {
                sh 'make init'
            }
          }
        }
        stage('Plan') {
          agent { label 'docker' }
          steps {
            tfsh {
                sh 'make plan'
                stash name: "terraform-plan", includes: "terraform-plan.out"
            }
          }
        }
        stage('Review') {
          when { branch 'master' }
          steps {
            timeout(30) {
                input message: "Apply the planned updates to DataDog?", ok: 'Apply'
            }
          }
        }
        stage('Apply') {
          agent { label 'docker' }
          steps {
            unstash name: "terraform-plan"
            tfsh {
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
