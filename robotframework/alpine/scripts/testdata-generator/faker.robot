*** Settings ***
Documentation     This is a common library for automation
Library	          FakerLibrary    locale=zh_cn

*** Variables ***
*** Keywords ***
GenerateName
    [Documentation]    using Faker Library to Generate Name
    ...    诸如：阳璐
    ${name}    Name 
    Log    ${name}    level=DEBUG
    [Return]    ${name}

GenerateIdNo
    [Documentation]    using Faker Library to Generate valid SSN
    ...    诸如：350583196603010976
    ${idno}=    Ssn
    Log    ${idno}    level=DEBUG
    [Return]    ${idno}

GenerateAddress
    [Documentation]    using Faker Library to Generate Address
    ...    诸如：浙江省艳市秀英张路L座 136185
    ${address}=    Address
    Log    ${address}    level=DEBUG
    [Return]    ${address}
    
GenerateMobile
    [Documentation]    using Faker Library to Generate valid Mobile
    ...    诸如：15869840863
    ${mobile}=    Phone Number
    Log    ${mobile}    level=DEBUG
    [Return]    ${mobile}
        
GenerateCardNo19
    [Documentation]    基于银行要求，生成19位长度的银联借记卡
    ...    诸如：6222988855714191182
    ${seqno}=    Evaluate    random.randint(10000000000, 99999999999)    modules=random, sys
    ${cardno}    Catenate    SEPARATOR=    62229888    ${seqno}
    Log    ${cardno}    level=DEBUG
    [Return]    ${cardno}

GenerateCardNo
    [Documentation]    基于银行要求，生成16位长度的银联借记卡
    ...    诸如：6222988812340036
    ${seqno}=    Evaluate    random.randint(12340010, 12340099)    modules=random, sys
    ${cardno}    Catenate    SEPARATOR=    62229888    ${seqno}
    Log    ${cardno}    level=DEBUG
    [Return]    ${cardno}
    
    
GenerateCorpName
    [Documentation]    using Faker Library to Generate Corp Name
    ...    诸如：鸿睿思博传媒有限公司
    ${name}    Company 
    Log    ${name}    level=DEBUG
    [Return]    ${name}    
                
GenerateEmail
    [Documentation]    using Faker Library to Generate Email Address
    ...    诸如：   jiejia@yi.cn
    ${email}    Company Email 
    Log    ${email}    level=DEBUG
    [Return]    ${email}    

GenerateIPv4
    [Documentation]    using Faker Library to Generate IP v4 Address
    ...    诸如：49.137.45.185
    ${ipv4}    Ipv 4 
    Log    ${ipv4}    level=DEBUG
    [Return]    ${ipv4}    