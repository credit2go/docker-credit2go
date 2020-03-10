*** Settings ***
Documentation    This is scripts to use Gitlab API v4
Library     RequestsLibrary
Library	    OperatingSystem
Library     String

*** Variables ***
${gitlab}    %{CI_API_V4_URL}
${token}    %{GITLAB_API_TOKEN}
${id}    %{CI_PROJECT_ID}

*** Keywords ***
OpenGitlab
    [Arguments]    ${gitlab}    ${token}
    &{headers}=  Create Dictionary  PRIVATE-TOKEN=${token}
    Create Session    gitlab    ${gitlab}    headers=&{headers}    timeout=60    verify=True
    ${resp}=    Head Request    gitlab    /version
    Should Be Equal As Numbers    ${resp.status_code}    200
    
ReadGitProjectInfo
    [Arguments]    ${id}
    ${resp}=    Get Request    gitlab    /projects/${id}
    Should Be Equal As Numbers    ${resp.status_code}    200
    ${name_with_namespace}    ${name}=    Split String From Right    ${resp.json()["name_with_namespace"]}    separator=/    max_split=1
    ${name_with_namespace}=    Strip String    ${name_with_namespace}
    ${path_with_namespace}    ${path}=    Split String From Right    ${resp.json()["path_with_namespace"]}    separator=/    max_split=1
    ${path_with_namespace}=    Strip String    ${path_with_namespace}
    ${name}=    Strip String    ${resp.json()["path"]}
    ${displayname}=    Strip String    ${resp.json()["name"]}
    ${description}=    Strip String    ${resp.json()["description"]}
    ${url}=     Strip String    ${resp.json()["http_url_to_repo"]}
    &{projectInfo}=    Create Dictionary
    ...    id=${id}
    ...    name=${name}    
    ...    displayname=${displayname}    
    ...    description=${description}    
    ...    name_with_namespace=${name_with_namespace}    
    ...    path_with_namespace=${path_with_namespace}    
    ...    http_url_to_repo=${resp.json()["http_url_to_repo"]}
	[Return]    &{projectInfo}