#!/bin/bash
#基于Git Lab地址自动创建相关的Jenkins项目

projecturl=$1
branchname=$2
gitrepo=$3
#转义处理
giturl=${gitrepo//\//\\\/}

gitlab=${CI_API_V4_URL}
gitlab=${gitlab%api/v4}
#转义处理
gitlab=${gitlab//\//\\\/}
jenkins=${JENKINS_URL}
#获取项目名称
projectname=${projecturl##*/job/}
projectname=${projectname%/}

#完整job当前路径，不含branch名称
foldername=${projecturl#$jenkins/}
foldername=${foldername%/job/$projectname/}
#将路径中job/去除	
foldername=${foldername//job\//}

user=${JENKINS_USER}
token=${JENKINS_TOKEN}
#加载最新的模板文件
#加载最新的模板文件
echo "Jenkins Project Path is: ${foldername}"
echo "Jenkins Project Path is: ${projectname}"

rm -rf /opt/jenkins/*.xml
curl -s --user $user:$token $jenkins/job/template/config.xml -o /opt/jenkins/folder.xml
curl -s --user $user:$token $jenkins/job/template/job/multibranch-pipeline/config.xml -o /opt/jenkins/job.xml

#按顺序检查文件夹路径
array=(${foldername//\// })  
url=$jenkins
for var in ${array[@]}
do
		#创建Jenkins项目，类型Folder
		url=$url/job/$var
		status=$(curl -s -I -X POST $url/ --user $user:$token|grep HTTP|awk {'print $2'})
		if [ "$status" -ne 200 ]
		then
			cp /opt/jenkins/folder.xml /opt/jenkins/$var.xml
			#修改displayname
			sed -i 's/模版项目/'$var'/g' /opt/jenkins/$var.xml
			sed -i 's/Jenkins各种模版项目/''/g' /opt/jenkins/$var.xml
			#Jenkins项目不存在，创建folder
			createurl=${url%/job/$var}
			curl -s -X POST $createurl'/createItem?name='$var --user $user:$token --data-binary @/opt/jenkins/$var.xml -H "Content-Type:text/xml"
			rm -f /opt/jenkins/$var.xml
		fi
done
#创建Jenkins 项目，类型MutliBranchPipeline
cp /opt/jenkins/job.xml /opt/jenkins/$projectname.xml
#修改displayname
sed -i 's/多分支GitLab流水线/'$projectname'/g' /opt/jenkins/$projectname.xml
#修改scm地址
sed -i 's/'$gitlab'/'$giturl'/g' /opt/jenkins/$projectname.xml
createurl=${projecturl%/job/$projectname/}	
curl -s -X POST $createurl'/createItem?name='$projectname --user $user:$token --data-binary @/opt/jenkins/$projectname.xml -H "Content-Type:text/xml"
rm -rf /opt/jenkins/$projectname.xml
echo "Jenkins Job has been created."
#触发初始化构建
curl -s -X POST $projecturl'/build?cause=initialize' --user $user:$token
exit 0