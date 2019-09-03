#!/bin/bash

string=${CI_PROJECT_DIR}
substring=/builds/gitlab
jenkins=${JENKINS_URL}
gitlab=${CI_API_V4_URL}
gitlab=${gitlab%api/v4}

gitrepo=${string#$substring}
branch=${CI_COMMIT_REF_NAME}
#Jenkins Job conf
job=$jenkins${gitrepo/////job/}
#job=${job%.git}/job/$branch
job=${job%.git}

#GitLab Job conf
gitrepo=$gitlab$gitrepo
user=${JENKINS_USER}
token=${JENKINS_TOKEN}

#Check Jenkins Server is accessible
status=$(curl -s --connect-timeout 10 -I $jenkins/ --user $user:$token |grep HTTP|awk {'print $2'})
if [ "$status" -ne 200 ]
then
	echo "Jenkins Server is not able to access"
	exit 1
fi

#Check Path, only trigger project and product
path=${gitrepo: 33 :7}
if [ "$path" == "project" ] || [ "$path" == "product" ]
then
  echo "Jenkins Project Address is: ${job}"
  echo "Git Url is : ${gitrepo}"
  echo "branch name is : ${branch}"
  #Always update job from template even job exists
  echo "Create or Update Jenkins Job"
  /bin/bash /opt/jenkins/createJenkinsJob.sh $job/ $branch $gitrepo

#  #Check Return Code to choose step
#  #check job exists or not, if job not exists, then create Jenkins job automaticlly and trigger the first build
#  status=$(curl -s -I $job/ --user $user:$token|grep HTTP|awk {'print $2'})
#  if [ "$status" -ne 200 ]
#  then
#  	echo "Jenkins Job not configure"
#  	/bin/bash /opt/jenkins/createJenkinsJob.sh $job/ $branch $gitrepo
#  else
#  	#job exists
#  	#Jenkins Job API Call or Scan Branch
#  	url=$job/build?cause=$newrev
#  	status=$(curl -s -I -X POST $url --user $user:$token|grep HTTP|awk {'print $2'})
#  	if [ "$status" -eq 404 ]
#  	then
#  		url=$job/buildWithParameters?cause=${CI_COMMIT_SHA}
#  		curl -s -X POST $url --user $user:$token
#  	fi
#  fi
  echo "Jenkins Job has been notified"
else
  echo "Jenkins is ignored as per its path: ${path} is not valid"
fi
