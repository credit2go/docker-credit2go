#!/bin/bash
#Use Jenkins API to create Job or Update Job
#this file trigger from GitLab-CI by using env defined in gitlab-runner

#define variable from input or env
robot --listener robotframework_reportportal.listener --variable RP_UUID:"f41c5d6d-d04c-4c4a-9d7c-2acc8edc2b63" --variable RP_ENDPOINT:"https://reportportal.credit2go.cn" --variable RP_LAUNCH:"jenkins-gitlab-hook" --variable RP_PROJECT:"jenkins" -l NONE -r NONE -o NONE -v jenkins:${JENKINS_URL} -v user:${JENKINS_USER} -v password:${JENKINS_TOKEN} -v gitlab:${CI_API_V4_URL} -v token:${GITLAB_API_TOKEN} -v id:${CI_PROJECT_ID} /opt

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