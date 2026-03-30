# Build report jobs to monitor for staleness
# Flat structure - each job is explicit with its controller and threshold
# Ref: https://github.com/jenkins-infra/helpdesk/issues/2843

build_report_jobs:
  docker-404:
    controller: infra.ci.jenkins.io
    job: docker-jobs/docker-404/main
    threshold_minutes: 1440
