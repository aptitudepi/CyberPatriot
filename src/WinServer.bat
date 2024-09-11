@echo off
setlocal enabledelayedexpansion
net session

if not %errorlevel%==0 ( 
	echo Administrator access is required to use this script.
	pause
	exit 
	) else (
	goto :main_menu
	)

cls

:main_menu
	cls
	echo Riot Vanguard Rootkit
	echo Note: Ensure you have attempted to complete the forensics questions before changing anything^^!
	echo 1) Set user properties      
	echo 2) View Network Shares      
	echo 3) Change user password to "Cyb3rPatr!0t$" (dont use right now)
	echo 4) Disable default guest and administrator account    
	echo 5) Modify password policy
	echo 6) Modify lockout Policy    
	echo 7) Enable Windows firewall
	echo 8) Disable services
        echo 9) Remote Desktop Config
	echo 10) Enable auto update      
	echo 11) Security options
	echo 12) Audit the machine
	echo 13) Find SHA256 hash of a file
 	echo R) Reboot       
	echo X) Exit                     
	echo XC) Exit and Remove
	set /p answer=Please choose an option: 
	if /i "%answer%"=="0" goto :blankFunction
	if /i "%answer%"=="1" goto :setUserProperities
	if /i "%answer%"=="2" goto :showNetworkShares
	if /i "%answer%"=="3" goto :changeUserPasswords
	if /i "%answer%"=="4" goto :disableDefaultAccounts
	if /i "%answer%"=="5" goto :modifyPasswordPolicy
	if /i "%answer%"=="6" goto :modifyLockoutPolicy
	if /i "%answer%"=="7" goto :modifyFirewall
	if /i "%answer%"=="8" goto :disableServices
	if /i "%answer%"=="9" goto :changeRemoteDesktop
	if /i "%answer%"=="10" goto :autoUpdate
	if /i "%answer%"=="11" goto :modifySecurityPolicies
	if /i "%answer%"=="12" goto :enableAuditing
	if /i "%answer%"=="13" goto :findHash
	if /i "%answer%"=="X" exit
	if /i "%answer%"=="XC" goto :clean
	if /i "%answer%"=="R" shutdown /r
	pause

:blankFunction
	echo Found invalid input...
	goto :main_menu

:setUserProperities
	echo Setting user account properties...
	wmic UserAccount set PasswordExpires=True
	wmic UserAccount set PasswordChangeable=True
	wmic UserAccount set PasswordRequired=True

	pause
	goto :main_menu

:clean
	del "%~f0"
	pause

:changeUserPasswords
	net user
	set /p user=Enter username or "Exit": 
	if %user%==Exit ( 
		goto :main_menu 
	) else (
	 	net user %user% Cyb3rPatr!0t$
	)
	goto :changeUserPasswords
	
:showNetworkShares
	cls
	net share
	pause
	goto :main_menu

:disableDefaultAccounts
	net user Guest | findstr Active | findstr Yes
	if %errorlevel%==0 (
		echo Guest account is already disabled.
	)
	if %errorlevel%==1 (
		net user guest Cyb3rPatr!0t$ /active:no
	)
	
	net user Administrator | findstr Active | findstr Yes
	if %errorlevel%==0 (
		echo Admin account is already disabled.
		pause
		goto :main_menu
	)
	if %errorlevel%==1 (
		net user administrator Cyb3rPatr!0t$ /active:no
		pause
		goto :main_menu
	)
	
:modifyPasswordPolicy
	echo Modifying password policy...
	net accounts /minpwlen:8
	net accounts /maxpwage:60
	net accounts /minpwage:10
	net accounts /uniquepw:3
	
	pause
	goto :main_menu
	
:modifyLockoutPolicy
	echo Modifying lockout policy...
	net accounts /lockoutduration:30
	net accounts /lockoutthreshold:6
	net accounts /lockoutwindow:30
	pause
	goto :main_menu
	
:modifyFirewall
	rem Enables firewall
	netsh advfirewall set allprofiles state on
	netsh advfirewall reset
	
	pause
	goto :main_menu

:disableServices
	echo Disabling Services
	sc stop TapiSrv
	sc config TapiSrv start= disabled
	sc stop TlntSvr
	sc config TlntSvr start= disabled
	sc stop ftpsvc
	sc config ftpsvc start= disabled
	sc stop SNMP
	sc config SNMP start= disabled
	sc stop SessionEnv
	sc config SessionEnv start= disabled
	sc stop TermService
	sc config TermService start= disabled
	sc stop UmRdpService
	sc config UmRdpService start= disabled
	sc stop SharedAccess
	sc config SharedAccess start= disabled
	sc stop remoteRegistry 
	sc config remoteRegistry start= disabled
	sc stop SSDPSRV
	sc config SSDPSRV start= disabled
	sc stop W3SVC
	sc config W3SVC start= disabled
	sc stop SNMPTRAP
	sc config SNMPTRAP start= disabled
	sc stop remoteAccess
	sc config remoteAccess start= disabled
	sc stop RpcSs
	sc config RpcSs start= disabled
	sc stop HomeGroupProvider
	sc config HomeGroupProvider start= disabled
	sc stop HomeGroupListener
	sc config HomeGroupListener start= disabled
	
	pause
	goto :main_menu

:changeRemoteDesktop
	set /p answer=Enable Remote Desktop? [y/n]
	if /I "%answer%"=="y" (
		reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
		echo Restart the computer to complete this action.
	)
	if /I "%answer%"=="n" (
		reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f
		echo Restart the computer to complete this action.
	)
	
	pause
	goto :main_menu
	
:autoUpdate
	rem Turn on automatic updates
	echo Turning on automatic updates
	reg add "HKLM\SOFTWARE\Microsoft\WINDOWS\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 4 /f

	pause
	goto :main_menu
	
:modifySecurityPolicies
	echo Modifying security policies..

	rem Restrict CD ROM drive
	reg ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AllocateCDRoms /t REG_DWORD /d 1 /f

	rem Automatic Admin logon
	reg ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_DWORD /d 0 /f
	
	rem Logon message text
	rem set /p body=Please enter logon text: 
	rem	reg ADD "HKLM\SYSTEM\microsoft\Windwos\CurrentVersion\Policies\System\legalnoticetext" /v LegalNoticeText /t REG_SZ /d "%body%"
	
	rem Logon message title bar
	rem set /p subject=Please enter the title of the message: 
	rem	reg ADD "HKLM\SYSTEM\microsoft\Windwos\CurrentVersion\Policies\System\legalnoticecaption" /v LegalNoticeCaption /t REG_SZ /d "%subject%"
	
	rem Wipe page file from shutdown
	reg ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 1 /f
	
	rem Disallow remote access to floppie disks
	reg ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AllocateFloppies /t REG_DWORD /d 1 /f
	
	rem Prevent print driver installs 
	reg ADD "HKLM\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" /v AddPrinterDrivers /t REG_DWORD /d 1 /f
	
	rem Limit local account use of blank passwords to console
	reg ADD "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 1 /f
	
	rem Auditing access of Global System Objects
	reg ADD "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v auditbaseobjects /t REG_DWORD /d 1 /f
	
	rem Auditing Backup and Restore
	reg ADD "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v fullprivilegeauditing /t REG_DWORD /d 1 /f
	
	rem Do not display last user on logon
	reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v dontdisplaylastusername /t REG_DWORD /d 1 /f
	
	rem UAC setting (Prompt on Secure Desktop)
	reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f
	
	rem Enable Installer Detection
	reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableInstallerDetection /t REG_DWORD /d 1 /f
	
	rem Undock without logon
	reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v undockwithoutlogon /t REG_DWORD /d 0 /f
	
	rem Maximum Machine Password Age
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v MaximumPasswordAge /t REG_DWORD /d 15 /f

	rem Disable machine account password changes
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v DisablePasswordChange /t REG_DWORD /d 1 /f
	
	rem Require Strong Session Key
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v RequireStrongKey /t REG_DWORD /d 1 /f
	
	rem Require Sign/Seal
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v RequireSignOrSeal /t REG_DWORD /d 1 /f
	
	rem Sign Channel
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v SignSecureChannel /t REG_DWORD /d 1 /f
	
	rem Seal Channel
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v SealSecureChannel /t REG_DWORD /d 1 /f
	
	rem Don't disable CTRL+ALT+DEL even though it serves no purpose
	reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v DisableCAD /t REG_DWORD /d 0 /f 
	
	rem Restrict Anonymous Enumeration #1
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v restrictanonymous /t REG_DWORD /d 1 /f 
	
	rem Restrict Anonymous Enumeration #2
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v restrictanonymoussam /t REG_DWORD /d 1 /f 
	
	rem Idle Time Limit - 45 mins
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v autodisconnect /t REG_DWORD /d 45 /f 
	
	rem Require Security Signature - Disabled pursuant to checklist
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v enablesecuritysignature /t REG_DWORD /d 0 /f 
	
	rem Enable Security Signature - Disabled pursuant to checklist
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v requiresecuritysignature /t REG_DWORD /d 0 /f 
	
	rem Disable Domain Credential Storage
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v disabledomaincreds /t REG_DWORD /d 1 /f 
	
	rem Don't Give Anons Everyone Permissions
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v everyoneincludesanonymous /t REG_DWORD /d 0 /f 
	
	rem SMB Passwords unencrypted to third party
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanWorkstation\Parameters /v EnablePlainTextPassword /t REG_DWORD /d 0 /f
	
	rem Null Session Pipes Cleared
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v NullSessionPipes /t REG_MULTI_SZ /d "" /f
	
	rem remotely accessible registry paths cleared
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedExactPaths /v Machine /t REG_MULTI_SZ /d "" /f
	
	rem remotely accessible registry paths and sub-paths cleared
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedPaths /v Machine /t REG_MULTI_SZ /d "" /f
	
	rem Restict anonymous access to named pipes and shares
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v NullSessionShares /t REG_MULTI_SZ /d "" /f
	
	rem Allow to use Machine ID for NTLM
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v UseMachineId /t REG_DWORD /d 0 /f

	rem Enables DEP
	bcdedit.exe /set {current} nx AlwaysOn
	pause
	goto :main_menu
	
:enableAuditing
	echo Enabling auditing
	auditpol /set /category:* /success:enable
	auditpol /set /category:* /failure:enable
	
	pause
	goto :main_menu

:findHash
	set /p path=Enter file path: 
	set /p algo=Enter algorithm: 
	echo -----------------------
	CertUtil -hashfile %path% %algo%

	pause
	goto :main_menu
	
endlocal