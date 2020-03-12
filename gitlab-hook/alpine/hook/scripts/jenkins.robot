*** Settings ***
Documentation    This is Jenkins API handle scripts for read/create/update job
Library     Collections
Library     RequestsLibrary
Library	    OperatingSystem
Library     XML

*** Variables ***
${jenkins}    %{JENKINS_URL}
${user}    %{JENKINS_USER}
${password}    %{JENKINS_TOKEN}

*** Keywords ***
CreateJenkinsJob
    [Documentation]    Create Jenkins Job by upload config.xml file
    [Arguments]    ${path}    ${name}    ${file}
    &{headers}=  Create Dictionary  Content-Type=application/xml
    ${resp}=    Post Request    jenkins    ${path}/createItem?name=${name}    headers=&{headers}    data=${file}    allow_redirects=true
    Should Be Equal As Numbers  ${resp.status_code}  200    

CloseConnection
    Delete All Sessions

OpenJenkins
    [Arguments]    ${jenkins}    ${user}    ${password}
    @{auth}=    Create List    ${user}    ${password}
    Create Session    jenkins    ${jenkins}    auth=@{auth}    timeout=60    verify=True
    ${resp}=    Head Request    jenkins    /
    Should Be Equal As Numbers    ${resp.status_code}    200

GetJenkinsTemplateFolder
    [Documentation]    Download config.xml for Jenkins Job, Type: Folder
    [Arguments]    ${uri}=/job/template/config.xml
    ${resp}=    Get Request    jenkins    ${uri}    allow_redirects=true
    Should Be Equal As Numbers  ${resp.status_code}  200
    Create File    /opt/jenkins/template/folder.xml    content=${resp.text}    encoding=UTF-8

GetJenkinsTemplateProject
    [Documentation]    Download config.xml for Jenkins Job, Type: multibranch-pipeline 
    [Arguments]    ${uri}=/job/template/job/multibranch-pipeline/config.xml
    ${resp}=    Get Request    jenkins    ${uri}	allow_redirects=true
    Should Be Equal As Numbers  ${resp.status_code}  200
    Create File    /opt/jenkins/template/project.xml    content=${resp.text}    encoding=UTF-8

SetJenkinsExecutionEnv
    [Documentation]    Write RobotFramework execution status, default false
    [Arguments]    ${result}
    Create File    /opt/hook.txt    content=${result}

SetJenkinsJob
    [Documentation]    Create or Update Jenkins Job    
    [Arguments]    ${job_create_path}    ${job_path}    ${name}
    ${files}=    Get Binary File    /opt/jenkins/job/${name}.xml
    #Check Job is exists or not
    ${resp}=    Head Request    jenkins    ${job_path}    allow_redirects=true
    Run Keyword If	${resp.status_code}==404    createJenkinsJob    path=${job_create_path}    name=${name}    file=${files}
    ...    ELSE IF    ${resp.status_code}==200    UpdateJenkinsJob    path=${job_path}    file=${files}

SetJenkinsFolderConfig
    [Documentation]    Write Jenkins Folder Config.xml
    [Arguments]    ${name}    ${displayname}    ${description}
    #Copy template XML
    Copy File    /opt/jenkins/template/folder.xml    /opt/jenkins/job/${name}.xml
    ${xml}=    Parse XML   /opt/jenkins/job/${name}.xml
    #Set Folder description
    Set Element Text    ${xml}    xpath=description    text=${description}
    #Set Folder display name
    Set Element Text    ${xml}    xpath=displayName    text=${displayname}
    #Save Changes
    Save Xml    ${xml}    /opt/jenkins/job/${name}.xml    encoding=UTF-8
    
SetJenkinsJobConfig
    [Documentation]    Write Jenkins Job Mutlibranch Source Config.xml
    [Arguments]    ${projectInfo}
    ${name}=    Get From Dictionary    ${projectInfo}    name
    #Copy template XML
    Copy File    /opt/jenkins/template/project.xml    /opt/jenkins/job/${name}.xml
    ${xml}=    Parse XML   /opt/jenkins/job/${name}.xml
    #Set Job description
    ${data}=    Get From Dictionary    ${projectInfo}    description
    Set Element Text    ${xml}    xpath=description    text=${data}       
    #Set Job display name
    ${data}=    Get From Dictionary    ${projectInfo}    displayname
    Set Element Text    ${xml}    xpath=displayName    text=${data} 
    #Set Job to disable by project archive status 
    ${data}=    Get From Dictionary    ${projectInfo}    archived
    Set Element Text    ${xml}    xpath=disabled    text=${data} 
    #Set Job Project parent path
    ${data}=    Get From Dictionary    ${projectInfo}    path_with_namespace
    Set Element Text    ${xml}    xpath=sources/data/jenkins.branch.BranchSource/source/projectOwner    text=${data} 
    #Set Job Project Path
    ${projectPath}=    Get From Dictionary    ${projectInfo}    path_with_namespace
    ${projectPath}=    Catenate    SEPARATOR=${EMPTY}    ${projectPath}    /       ${name}
    Set Element Text    ${xml}    text=${projectPath}    xpath=sources/data/jenkins.branch.BranchSource/source/projectPath
    #Set Job Project Id
    ${data}=    Get From Dictionary    ${projectInfo}    id
    Set Element Text    ${xml}    text=${data}        xpath=sources/data/jenkins.branch.BranchSource/source/projectId
    #Set Job Project UUID, currently use project Id
    Set Element Text    ${xml}    text=${data}    xpath=sources/data/jenkins.branch.BranchSource/source/id
    #Save Changes
    Save Xml    ${xml}    /opt/jenkins/job/${name}.xml    encoding=UTF-8

TriggerJenkinsJobBuild
	[Documentation]    Trigger Jenkins Job to Run
	[Arguments]    ${path}
    ${resp}=    Post Request    jenkins    ${path}/build?cause=initialize    allow_redirects=true
    Should Be Equal As Numbers  ${resp.status_code}  200
    
UpdateJenkinsJob
    [Documentation]    Update Jenkins Job by upload config.xml file
    [Arguments]    ${path}    ${file}
    ${resp}=    Post Request    jenkins    ${path}/config.xml    data=${file}    allow_redirects=true
    Should Be Equal As Numbers  ${resp.status_code}  200        