#!/bin/bash
#Use Jenkins API to create Job or Update Job
#this file trigger from GitLab-CI by using env defined in gitlab-runner

#define variable from input or env
robot -l NONE -r NONE -o NONE -v jenkins:${JENKINS_URL} -v user:${JENKINS_USER} -v password:${JENKINS_TOKEN} -v gitlab:${CI_API_V4_URL} -v token:${GITLAB_API_TOKEN} -v id:${CI_PROJECT_ID} /opt

#Read job trigger status
status=$(cat /opt/hook.txt)
#Check status
if [ "$status" == "true" ]
then
  echo "Jenkins Job has been notified"
  exit 0
else
  echo "Jenkins Job trigger failed"
  exit 1
fi
