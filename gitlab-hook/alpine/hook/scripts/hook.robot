*** Settings ***
Documentation    This is Jenkins API handle scripts for read/create/update job
Library     Collections
Library     String
Resource    ./gitlab.robot
Resource    ./jenkins.robot

*** Variables ***
${template_folder}    /job/template/config.xml
${template_gitlab_branch}    /job/template/job/multibranch-pipeline/config.xml 

***Test Case***
hook
    SetJenkinsExecutionEnv    false
    OpenJenkins    jenkins=${jenkins}    user=${user}    password=${password}
    OpenGitlab    gitlab=${gitlab}    token=${token}
    #Read Project Info from Gitlab API
    &{project}=    ReadGitProjectInfo    id=${id}
    #Read Jenkins Template Job From Jenkins Server
    GetJenkinsTemplateFolder    uri=${template_folder}
    GetJenkinsTemplateProject    uri=${template_gitlab_branch}
    #Create or Update Jenkins Job, Type is Folder
    ${name}=    Get From Dictionary    ${project}    name
    ${path_with_namespace}=    Get From Dictionary    ${project}    path_with_namespace
    ${name_with_namespace}=    Get From Dictionary    ${project}    name_with_namespace
    @{folder}=    Split String    ${path_with_namespace}    separator=/
    @{folder_name}=    Split String    ${name_with_namespace}    separator=/
    ${length}=    Get Length    ${folder}
    ${path}=    Set Variable    ${EMPTY}
    ${path}=    Run Keyword If	${length}>1    recursiveFolder    ${path}    ${folder}    ${folder_name}           
    #Create or Update Jenkins Job
    ${create_path}=    Set Variable    ${path}
    ${path}=    Catenate    SEPARATOR=${EMPTY}    ${path}    /job/${name}
    SetJenkinsJobConfig    projectInfo=${project}
    SetJenkinsJob    job_create_path=${create_path}    job_path=${path}    name=${name}
    #Trigger Jenkins Job
    TriggerJenkinsJobBuild    path=${path}
    CloseConnection
    SetJenkinsExecutionEnv    true
    
***Keywords***    
recursiveFolder
    [Arguments]    ${path}    ${folder}    ${folder_name}
    FOR    ${index}    ${name}    IN ENUMERATE     @{folder}
        ${create_path}=    Set Variable    ${path}
        ${name}=    Strip String    ${name}
        ${path}=    Strip String    ${path}
        ${path}=    Catenate    SEPARATOR=${EMPTY}    ${path}    /job/${name}
        ${path}=    Strip String    ${path}
        ${displayname}=    Get From List    ${folder_name}    ${index}
        ${displayname}=    Strip String    ${displayname}
        SetJenkinsFolderConfig    name=${name}    displayname=${displayname}    description=${displayname}
        SetJenkinsJob    job_create_path=${create_path}    job_path=${path}    name=${name}        
    END
    [RETURN]    ${path}