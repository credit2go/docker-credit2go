*** Settings ***
Resource	faker.robot
Library	    OperatingSystem

*** Variables ***
${loop}    1    #interation number

*** Test Case ***
TestDataGenerator
    ${loop}=    Evaluate    ${loop}+1
    Append To File    testdata.html    <table>
    Append To File    testdata.html    <tr><td>序号</td><td>姓名</td><td>身份证</td><td>地址</td><td>电话</td><td>银行卡</td></tr>    encoding=UTF-8
    FOR    ${index}    IN RANGE    1    ${loop}
        ${姓名}=    GenerateName
		${身份证}=    GenerateIdNo
		${电话}=    GenerateMobile
		${银行卡}=    GenerateCardNo
		${地址}=    GenerateAddress
		Append To File    testdata.html    <tr><td>${index}</td><td>${姓名}</td><td>${身份证}</td><td>${地址}</td><td>${电话}</td><td>${银行卡}</td></tr>    encoding=UTF-8
    END
	Append To File    testdata.html    </table>