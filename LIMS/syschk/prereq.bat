@echo off
cd %userprofile%\Desktop
CHOICE /C 12 /N /M "Check prerequisites for.... (1) 2012 (2) 2008"
echo
IF ERRORLEVEL 2 GOTO 2008
IF ERRORLEVEL 1 GOTO 2012


:2008
CHOICE /C 1234 /N /M "Check prerequisites for.... (1) LES (2) LIMS (3) LES Client (4) BOTH"
echo
IF ERRORLEVEL 4 GOTO BOTH08
IF ERRORLEVEL 3 GOTO CLIENT08
IF ERRORLEVEL 2 GOTO LIMS08
IF ERRORLEVEL 1 GOTO LES08

:2012
CHOICE /C 12345678 /N /M "Check prerequisites for.... (1) LES (2) LIMS (3) LES Client (4) BOTH"
echo
IF ERRORLEVEL 4 GOTO BOTH12
IF ERRORLEVEL 3 GOTO CLIENT12
IF ERRORLEVEL 2 GOTO LIMS12
IF ERRORLEVEL 1 GOTO LES12



:LES08
rem ---------------------------------------------------------------------------------------------------------------------------------------
echo LES v3.x APPLICATION SERVER PREREQUISITE CHECK
echo LES v3.x APPLICATION SERVER PREREQUISITE CHECK >> sysinfo.txt
echo. >> sysinfo.txt
set dt=%date:~4,2%-%date:~7,2%-%date:~10,4%_%time:~0,2%%time:~3,2%
echo %dt% >> sysinfo.txt
echo. >> sysinfo.txt

wmic computersystem get name | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo CPU ------------------------------------ >> sysinfo.txt
wmic cpu get name | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo 4000000000 or greater of Memory  ------------------------------------ >> sysinfo.txt
wmic COMPUTERSYSTEM get TotalPhysicalMemory | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo 200000000000 or greater of FreeSpace  ------------------------------------ >> sysinfo.txt
wmic logicaldisk where drivetype=3 get Name,Size,Freespace | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo OS ------------------------------------ >> sysinfo.txt
echo English - United States    en   en-us      1252      409                    1033 >> sysinfo.txt
wmic os get ServicePackMajorVersion,Caption,OSArchitecture,locale, oslanguage, codeset | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt


echo ----------------------------------- Software Requirements ------------------------------------ >> sysinfo.txt
echo. >> sysinfo.txt

echo Oracle Client 11g or higher 32-bit clients only-------------- >> sysinfo.txt
tnsping >> oracle.txt
FOR /F "tokens=5,7,8 delims= " %%i IN ('findstr /i /c:"Utility" oracle.txt') DO @echo %%j %%k %%i >> sysinfo.txt
echo. >> sysinfo.txt
echo. >> sysinfo.txt

echo .NET Framework v3.5.1 or higher ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Microsoft .NET%%'" get Name, Version | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo Microsoft Word 2003, 2007, 2010, 2013 ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Microsoft%%Word%%'" get Name| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo MSXML3 8.20.8730.1 or higher ------------------------------------ >> sysinfo.txt
wmic datafile where name='c:\\windows\\system32\\msxml3.dll' get name, version | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo Adobe Reader  9, 10 or 11 ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Adobe%%'" get Name, Version| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo System Cryptography FIPS 0=Disabled ------------------------------------------  >> sysinfo.txt
Reg query "HKLM\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" >> sysinfo.txt
echo. >> sysinfo.txt

echo MSDTC Running? ------------------------------------ >> sysinfo.txt
wmic service where "Name like '%%MSDTC%%'" get Name, state  | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo Accelrys Products Installed ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Accelrys%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
wmic product where "Name like '%%VelQuest%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
rem wmic product where "Name like '%%Accelrys%%'" get Name, Version >> sysinfo.txt 2>>&1
echo. >> sysinfo.txt

del oracle.txt

echo.
echo .Net v3.5.1 Feature  ------------------------------------ 
echo servermanagercmd -query ^>^> roles.txt > iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[X]" roles.txt') do @echo %%%%i ^>^> services.txt >> iisquery.bat
echo echo ------Features----- ^>^> installed.txt >> iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[NET-Framework" services.txt') do @echo %%%%i ^>^> installed.txt >> iisquery.bat
call iisquery.bat
del roles.txt
del services.txt
start /wait notepad installed.txt 
del installed.txt
del iisquery.bat

rem ---------------------
SET /P answer=Is .NET 3.5.1 Feature configured as expected? (y or n)
echo .NET 3.5.1 Feature was configured as expected: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
echo.

echo Word and Excel DCOM Settings  ------------------------------------ 
c:\windows\syswow64\mmc comexp.msc /32
echo.
SET /P answer=Word and Excel DCOM Settings are visible? (y or n)
echo Word and Excel DCOM Settings are visible: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Wait for Users and Groups Dialog
echo.
echo Local Group with Global Group, Global Group with susr, susr in Admin group and Global group in Distributed COM Users
lusrmgr.msc
echo.
SET /P answer=Are groups configured as expected? (y or n)
echo Groups are configured as expected: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
echo.

SET /P group=Please enter the ePMC_Users group name or 'unknown': (find susr in group)
net group /Domain %group%
echo.
SET /P answer=Is System User in the global group? (y or n)
echo System User is in the global group %group%: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


rem -----------------------
echo.
echo Wait for test.udl to be created on desktop
copy nul %userprofile%\Desktop\test.udl
pause
echo.
echo Check for Oracle Provider for OLE DB
C:\Windows\syswow64\rundll32.exe "C:\Program Files (x86)\Common Files\System\Ole DB\oledb32.dll",OpenDSLFile %userprofile%\Desktop\test.udl 
SET /P answer=Oracle Provider for OLE DB is present? (y or n)
echo Oracle Provider for OLE DB is present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
del %userprofile%\Desktop\test.udl


rem ----------------------------------
echo.
echo Checking for TNSNames.ora
for /f %%a in ('reg query hklm\software\wow6432node\oracle /f key^|FIND /I "KEY"') do (
set key=%%a
)
set DspName=Not Found
for /f "Tokens=2*" %%a in ('reg query %key% /V ORACLE_HOME^|Find "REG_SZ"') do (
set DspName=%%b
)
start /wait notepad %DspName%\network\admin\tnsnames.ora
SET /P answer=TNSNAMES.ORA file is present and configured? (y or n)
echo TNSNAMES.ORA file is present and configured: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check connection to the database.  The following script can be used to confirm.
echo SELECT * FROM NLS_DATABASE_PARAMETERS where parameter='NLS_CHARACTERSET';
echo SELECT * FROM dba_role_privs where granted_role='DBA';
echo column file_name format a50;
echo Select file_name, AUTOEXTENSIBLE from dba_data_files;
echo.
start sqlplus
SET /P answer=Able to connect to database? (y or n)
echo Able to connect to database: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
start /wait winword.exe
SET /P answer=MSWord opens successfully? (y or n)
echo MSWord opens successfully: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check for IPv6 Interfaces  Look for addresses with ::
WMIC NICCONFIG WHERE IPENABLED=TRUE GET Description,IPADDRESS /FORMAT:LIST
SET /P answer=There are no IPv6 interfaces present? (y or n)
echo IPv6 interfaces were not present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


rem -------------------------------
echo.
echo Turn the firewall off
start /wait control firewall.cpl
SET /P answer=Firewalls are off? (y or n)
echo Firewalls are off: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo msgbox "Check for BIOVIA Software Installer Downloads!" > "%temp%\popup.vbs"
wscript.exe "%temp%\popup.vbs"
del %temp%\popup.vbs
SET /P answer=Installation media has been downloaded? (y or n)
echo Installation media has been downloaded: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

echo.
echo.
echo Review the sysinfo file and close when done.
start /wait notepad sysinfo.txt

echo All Done......
ren sysinfo.txt les_app_svr_%dt%.txt

GOTO END



:LIMS08
rem ----------------------------------------------------------------------------------------------------------------------------------
echo LIMS v4.2 APPLICATION SERVER PREREQUISITE CHECK
echo LIMS v4.2 APPLICATION SERVER PREREQUISITE CHECK >> sysinfo.txt
echo. >> sysinfo.txt
set dt=%date:~4,2%-%date:~7,2%-%date:~10,4%_%time:~0,2%%time:~3,2%
echo %dt% >> sysinfo.txt
echo. >> sysinfo.txt

wmic computersystem get name |find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo CPU ------------------------------------ >> sysinfo.txt
wmic cpu get name | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo 4000000000 or greater of Memory  ------------------------------------ >> sysinfo.txt
wmic COMPUTERSYSTEM get TotalPhysicalMemory | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo 200000000000 or greater of FreeSpace  ------------------------------------ >> sysinfo.txt
wmic logicaldisk where drivetype=3 get Name,Size,Freespace | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo OS ------------------------------------ >> sysinfo.txt
echo English - United States    en   en-us      1252      409                    1033 >> sysinfo.txt
wmic os get ServicePackMajorVersion,Caption,OSArchitecture,locale, oslanguage, codeset | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt


echo ----------------------------------- Software Requirements ------------------------------------ >> sysinfo.txt
echo. >> sysinfo.txt

echo Oracle Client 11g or higher 32-bit clients only-------------- >> sysinfo.txt
tnsping >> oracle.txt
FOR /F "tokens=5,7,8 delims= " %%i IN ('findstr /i /c:"Utility" oracle.txt') DO @echo %%j %%k %%i >> sysinfo.txt
echo. >> sysinfo.txt

echo .NET Framework v4.5 or higher ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Microsoft .NET%%'" get Name, Version | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo Internet Explorer 9, 10 or 11 ------------------------------------ >> sysinfo.txt
set alias=Reg query "HKLM\SOFTWARE\Microsoft\Internet Explorer\Version Vector"
FOR /F "TOKENS=1,3 DELIMS=	 " %%A IN ('%alias%^|FIND /I "IE"') DO ECHO %%A %%B >> sysinfo.txt
echo. >> sysinfo.txt

echo Internet Information Server (IIS) ------------------------------------ >> sysinfo.txt
set alias2=Reg query "HKLM\Software\Microsoft\InetStp"
FOR /F "TOKENS=3,4 DELIMS=	 " %%A IN ('%alias2%^|FIND /I "VersionString"') DO ECHO %%A %%B >> sysinfo.txt
echo. >> sysinfo.txt

echo SAP Crystal Reports Runtime v13.0.3 or 13.0.12 32-bit ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%crystal%%'" get Name, Version | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo Adobe Reader  9.4 or higher ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Adobe%%'" get Name, Version| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo Microsoft Silverlight v3 or higher ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Silverlight%%'" get Name, Version| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo System Cryptography FIPS 0=Disabled ------------------------------------------  >> sysinfo.txt
Reg query "HKLM\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" >> sysinfo.txt
echo. >> sysinfo.txt

echo BIOVIA Products Installed ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Accelrys%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
wmic product where "Name like '%%VelQuest%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
rem wmic product where "Name like '%%Accelrys%%'" get Name, Version >> sysinfo.txt 2>>&1
echo. >> sysinfo.txt

del oracle.txt

rem ----------------------
echo servermanagercmd -query ^>^> roles.txt > iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[X]" roles.txt') do @echo %%%%i ^>^> services.txt >> iisquery.bat
echo echo ------Roles--------- ^>^> installed.txt >> iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[Web" services.txt') do @echo %%%%i ^>^> installed.txt >> iisquery.bat
echo echo ------Features----- ^>^> installed.txt >> iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[NET-Framework" services.txt') do @echo %%%%i ^>^> installed.txt >> iisquery.bat
call iisquery.bat
del roles.txt
del services.txt
echo Slide this page to the side to compare >> iis.txt
echo.		>> iis.txt
echo.		>> iis.txt
echo	1 Common Http Features:	>> iis.txt
echo	   Static Content	>> iis.txt
echo	   Default Document	>> iis.txt
echo	   Directory Browsing	>> iis.txt
echo	   HTTP Errors	>> iis.txt

echo	2 Application Development Features:	>> iis.txt
echo	   ASP.NET	>> iis.txt
echo	   .NET Extensibility	>> iis.txt
echo	   ISAPI Extensions	>> iis.txt
echo	   ISAPI Filters	>> iis.txt

echo	3 Health and Diagnostics:	>> iis.txt
echo	   HTTP Logging	>> iis.txt
echo	   Request Monitor	>> iis.txt

echo	4 Security:	>> iis.txt
echo	   Basic Authentication	>> iis.txt
echo	   Windows Authentication	>> iis.txt
echo	   Request Filtering	>> iis.txt

echo	5 Performance Features:	>> iis.txt
echo	   Static Content Compression	>> iis.txt

echo	6 Web Management Tools:	>> iis.txt
echo	   IIS Management Console	>> iis.txt
echo	   IIS6 Management Compatibility	>> iis.txt
echo            IIS 6 Metabase Compatibility  [Web-Metabase]    >> iis.txt
echo            IIS 6 WMI Compatibility  [Web-WMI]    >> iis.txt
echo            IIS 6 Scripting Tools  [Web-Lgcy-Scripting]    >> iis.txt
echo            IIS 6 Management Console  [Web-Lgcy-Mgmt-Console] >> iis.txt

echo ------Features-----  >> iis.txt
echo     .NET Framework 3.5.1 Features  [NET-Framework]    >> iis.txt
echo         .NET Framework 3.5.1  [NET-Framework-Core] >> iis.txt


echo.
echo Look for IIS Settings AND comparison lists 
start notepad iis.txt
start /wait notepad installed.txt 
del installed.txt
del iis.txt
del iisquery.bat

rem ---------------------
echo.
SET /P answer=Was IIS configured as expected? (y or n)
echo IIS was configured as expected: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check for Code 39 and Arial Unicode MS
start /wait control fonts
echo.
SET /P answer=Were Code 39 and Arial Unicode MS present? (y or n)
echo Code 39 and Arial Unicode MS were present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check for IPv6 Interfaces  Look for addresses with ::
WMIC NICCONFIG WHERE IPENABLED=TRUE GET Description,IPADDRESS /FORMAT:LIST
SET /P answer=There are no IPv6 interfaces present? (y or n)
echo IPv6 interfaces were not present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


rem ----------------------
echo.
echo Wait for IE ESC Dialog
"C:\Windows\system32\rundll32.exe" C:\Windows\system32\iesetup.dll,IEShowHardeningDialog
SET /P answer=IE Enhanced Security is off? (y or n)
echo IE Enhanced Security is off: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem -----------------------
echo.
echo Wait for test.udl to be created on desktop
copy nul %userprofile%\Desktop\test.udl
pause
echo.
echo Check for Oracle Provider for OLE DB
C:\Windows\syswow64\rundll32.exe "C:\Program Files (x86)\Common Files\System\Ole DB\oledb32.dll",OpenDSLFile %userprofile%\Desktop\test.udl 
SET /P answer=Oracle Provider for OLE DB is present? (y or n)
echo Oracle Provider for OLE DB is present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
del %userprofile%\Desktop\test.udl


rem ----------------------------------
echo.
echo Checking for TNSNames.ora
for /f %%a in ('reg query hklm\software\wow6432node\oracle /f key^|FIND /I "KEY"') do (
set key=%%a
)
set DspName=Not Found
for /f "Tokens=2*" %%a in ('reg query %key% /V ORACLE_HOME^|Find "REG_SZ"') do (
set DspName=%%b
)
start /wait notepad %DspName%\network\admin\tnsnames.ora
SET /P answer=TNSNAMES.ORA file is present and configured? (y or n)
echo TNSNAMES.ORA file is present and configured: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check connection to the database.  The following script can be used to confirm.
echo SELECT * FROM NLS_DATABASE_PARAMETERS where parameter='NLS_CHARACTERSET';
echo SELECT * FROM dba_role_privs where granted_role='DBA';
echo column file_name format a50;
echo Select file_name, AUTOEXTENSIBLE from dba_data_files;
echo.
start sqlplus
SET /P answer=Able to connect to database? (y or n)
echo Able to connect to database: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem -------------------------------
echo.
echo Turn the firewall off
start /wait control firewall.cpl
SET /P answer=Firewalls are off? (y or n)
echo Firewalls are off: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo msgbox "Check for BIOVIA Software Installer Downloads!" > "%temp%\popup.vbs"
wscript.exe "%temp%\popup.vbs"
del %temp%\popup.vbs
SET /P answer=Installation media has been downloaded? (y or n)
echo Installation media has been downloaded: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


echo.
echo.
echo Review the sysinfo file and close when done.
start /wait notepad sysinfo.txt

ren sysinfo.txt lims_app_svr_%dt%.txt

echo All Done......
GOTO END



:CLIENT08
rem --------------------------------------------------------------------------------------------------------------------------------------
echo LES v3.x CLIENT SERVER PREREQUISITE CHECK
echo LES v3.x CLIENT SERVER PREREQUISITE CHECK >> sysinfo.txt
echo. >> sysinfo.txt
set dt=%date:~4,2%-%date:~7,2%-%date:~10,4%_%time:~0,2%%time:~3,2%
echo %dt% >> sysinfo.txt
echo. >> sysinfo.txt

wmic computersystem get name |find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo CPU ------------------------------------ >> sysinfo.txt
wmic cpu get name | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo 4000000000 or greater of Memory  ------------------------------------ >> sysinfo.txt
wmic COMPUTERSYSTEM get TotalPhysicalMemory | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo 200000000000 or greater of FreeSpace  ------------------------------------ >> sysinfo.txt
wmic logicaldisk where drivetype=3 get Name,Size,Freespace | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo OS ------------------------------------ >> sysinfo.txt
echo English - United States    en   en-us      1252      409                    1033 >> sysinfo.txt
wmic os get ServicePackMajorVersion,Caption,OSArchitecture,locale, oslanguage, codeset | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt


echo ----------------------------------- Software Requirements ------------------------------------ >> sysinfo.txt
echo. >> sysinfo.txt

echo Oracle Client 11g or higher 32-bit clients only-------------- >> sysinfo.txt
tnsping >> oracle.txt
FOR /F "tokens=5,7,8 delims= " %%i IN ('findstr /i /c:"Utility" oracle.txt') DO @echo %%j %%k %%i >> sysinfo.txt
echo. >> sysinfo.txt

echo .NET Framework v3.5.1 or higher ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Microsoft .NET%%'" get Name, Version | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo MSXML3 8.20.8730.1 or higher ------------------------------------ >> sysinfo.txt
wmic datafile where name='c:\\windows\\system32\\msxml3.dll' get name, version | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo Microsoft Word   Any Version------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Microsoft%%Word%%'" get Name| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo Microsoft Excel   Any Version------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Microsoft%%Excel%%'" get Name| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo Adobe Reader  Any Version------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Adobe%%'" get Name, Version| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo System Cryptography FIPS 0=Disabled ------------------------------------------  >> sysinfo.txt
Reg query "HKLM\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" >> sysinfo.txt
echo. >> sysinfo.txt

echo BIOVIA Products Installed ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Accelrys%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
wmic product where "Name like '%%VelQuest%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
rem wmic product where "Name like '%%Accelrys%%'" get Name, Version >> sysinfo.txt 2>>&1
echo. >> sysinfo.txt

del oracle.txt


rem -----------------------
echo.
echo Wait for test.udl to be created on desktop
copy nul %userprofile%\Desktop\test.udl
pause
echo.
echo Check for Oracle Provider for OLE DB
C:\Windows\syswow64\rundll32.exe "C:\Program Files (x86)\Common Files\System\Ole DB\oledb32.dll",OpenDSLFile %userprofile%\Desktop\test.udl 
SET /P answer=Oracle Provider for OLE DB is present? (y or n)
echo Oracle Provider for OLE DB is present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
del %userprofile%\Desktop\test.udl


rem ----------------------------------
echo.
echo Checking for TNSNames.ora
for /f %%a in ('reg query hklm\software\wow6432node\oracle /f key^|FIND /I "KEY"') do (
set key=%%a
)
set DspName=Not Found
for /f "Tokens=2*" %%a in ('reg query %key% /V ORACLE_HOME^|Find "REG_SZ"') do (
set DspName=%%b
)
start /wait notepad %DspName%\network\admin\tnsnames.ora
SET /P answer=TNSNAMES.ORA file is present and configured? (y or n)
echo TNSNAMES.ORA file is present and configured: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check connection to the database.  The following script can be used to confirm.
echo SELECT * FROM NLS_DATABASE_PARAMETERS where parameter='NLS_CHARACTERSET';
echo SELECT * FROM dba_role_privs where granted_role='DBA';
echo column file_name format a50;
echo Select file_name, AUTOEXTENSIBLE from dba_data_files;
echo.
start sqlplus
SET /P answer=Able to connect to database? (y or n)
echo Able to connect to database: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


rem -----------------------
echo.
echo Verify file associations for doc dat and pdf
copy nul %userprofile%\Desktop\test.doc
copy nul %userprofile%\Desktop\test.dat
copy nul %userprofile%\Desktop\test.pdf
rem --------------------
rem create reg file to make dat assoc. in HKLM
echo.
echo Double click dat.reg to set .dat association for all users
echo.
echo	Windows Registry Editor Version 5.00	>> dat.reg
echo.		>> dat.reg
echo.		>> dat.reg
echo	[HKEY_LOCAL_MACHINE\Software\Classes\.dat]	>> dat.reg
echo	@="dat_auto_file"	>> dat.reg
echo.		>> dat.reg
echo	[HKEY_LOCAL_MACHINE\Software\Classes\dat_auto_file]	>> dat.reg
echo	@=""	>> dat.reg
echo.		>> dat.reg
echo	[HKEY_LOCAL_MACHINE\Software\Classes\dat_auto_file\shell]	>> dat.reg
echo.		>> dat.reg
echo	[HKEY_LOCAL_MACHINE\Software\Classes\dat_auto_file\shell\edit]	>> dat.reg
echo.		>> dat.reg
echo	[HKEY_LOCAL_MACHINE\Software\Classes\dat_auto_file\shell\edit\command]	>> dat.reg
echo	@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,4e,00,4f,00,54,00,45,00,50,00,41,00,44,00,2e,00,45,00,58,00,45,00,20,00,25,00,31,00,00,00	>> dat.reg
echo.		>> dat.reg
echo	[HKEY_LOCAL_MACHINE\Software\Classes\dat_auto_file\shell\open]	>> dat.reg
echo.		>> dat.reg
echo	[HKEY_LOCAL_MACHINE\Software\Classes\dat_auto_file\shell\open\command]	>> dat.reg
echo	@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,4e,00,4f,00,54,00,45,00,50,00,41,00,44,00,2e,00,45,00,58,00,45,00,20,00,25,00,31,00,00,00	>> dat.reg
rem -----------------  
pause
del test.doc
del test.dat
del test.pdf
del dat.reg

SET /P answer=File associations set? (y or n)
echo File associations set: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
start /wait winword.exe
SET /P answer=MSWord opens successfully? (y or n)
echo MSWord opens successfully: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


rem ----------------------
echo.
start /wait excel.exe
SET /P answer=MSExcel opens successfully? (y or n)
echo MSExcel opens successfully: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
 

rem ----------------------
echo.
echo Check for IPv6 Interfaces  Look for addresses with ::
WMIC NICCONFIG WHERE IPENABLED=TRUE GET Description,IPADDRESS /FORMAT:LIST
SET /P answer=There are no IPv6 interfaces present? (y or n)
echo IPv6 interfaces were not present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


rem -------------------------------
echo.
echo Turn the firewall off
start /wait control firewall.cpl
SET /P answer=Firewalls are off? (y or n)
echo Firewalls are off: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

echo.
echo.
echo Review the sysinfo file and close when done.
start /wait notepad sysinfo.txt

echo All Done......
ren sysinfo.txt les_app_svr_%dt%.txt


GOTO END


:BOTH08
rem ---------------------------------------------------------------------------------------------------------------------------------------
echo LES v3.x and LIMS v4.2 APPLICATION SERVER PREREQUISITE CHECK
echo LES v3.x and LIMS v4.2 APPLICATION SERVER PREREQUISITE CHECK >> sysinfo.txt
set dt=%date:~4,2%-%date:~7,2%-%date:~10,4%_%time:~0,2%%time:~3,2%
echo %dt% >> sysinfo.txt
echo. >> sysinfo.txt

wmic computersystem get name | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- CPU ------------------------------------ >> sysinfo.txt
wmic cpu get name | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- 4000000000 or greater of Memory  ------------------------------------ >> sysinfo.txt
wmic COMPUTERSYSTEM get TotalPhysicalMemory | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- 200000000000 or greater of FreeSpace  ------------------------------------ >> sysinfo.txt
wmic logicaldisk where drivetype=3 get Name,Size,Freespace | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- OS ------------------------------------ >> sysinfo.txt
echo English - United States    en   en-us      1252      409                    1033 >> sysinfo.txt
wmic os get ServicePackMajorVersion,Caption,OSArchitecture,locale, oslanguage, codeset | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt


echo ----------------------------------- Software Requirements ------------------------------------ >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Oracle Client 11g or higher 32-bit clients only-------------- >> sysinfo.txt
tnsping >> oracle.txt
FOR /F "tokens=5,7,8 delims= " %%i IN ('findstr /i /c:"Utility" oracle.txt') DO @echo %%j %%k %%i >> sysinfo.txt
echo. >> sysinfo.txt
echo. >> sysinfo.txt

echo .NET Framework v4.5 or higher ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Microsoft .NET%%'" get Name, Version | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo Internet Explorer 9, 10 or 11 ------------------------------------ >> sysinfo.txt
set alias=Reg query "HKLM\SOFTWARE\Microsoft\Internet Explorer\Version Vector"
FOR /F "TOKENS=1,3 DELIMS=	 " %%A IN ('%alias%^|FIND /I "IE"') DO ECHO %%A %%B >> sysinfo.txt
echo. >> sysinfo.txt

echo Internet Information Server (IIS) ------------------------------------ >> sysinfo.txt
set alias2=Reg query "HKLM\Software\Microsoft\InetStp"
FOR /F "TOKENS=3,4 DELIMS=	 " %%A IN ('%alias2%^|FIND /I "VersionString"') DO ECHO %%A %%B >> sysinfo.txt
echo. >> sysinfo.txt

echo SAP Crystal Reports Runtime v13.0.3 or 13.0.12 32-bit ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%crystal%%'" get Name, Version | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Microsoft Word 2003, 2007, 2010, 2013(requires configuration) ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Microsoft%%Word%%'" get Name| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- MSXML3 8.20.8730.1 or higher ------------------------------------ >> sysinfo.txt
wmic datafile where name='c:\\windows\\system32\\msxml3.dll' get name, version | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Adobe Reader  9.4, 10 or 11 ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Adobe%%'" get Name, Version| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo Microsoft Silverlight v3 or higher ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Silverlight%%'" get Name, Version| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- System Cryptography FIPS 0=Disabled ------------------------------------------  >> sysinfo.txt
Reg query "HKLM\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- MSDTC Running? ------------------------------------ >> sysinfo.txt
wmic service where "Name like '%%MSDTC%%'" get Name, state  | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- BIOVIA Products Installed ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Accelrys%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
wmic product where "Name like '%%VelQuest%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
rem wmic product where "Name like '%%Accelrys%%'" get Name, Version >> sysinfo.txt 2>>&1
echo. >> sysinfo.txt

del oracle.txt

rem ----------------------
echo servermanagercmd -query ^>^> roles.txt > iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[X]" roles.txt') do @echo %%%%i ^>^> services.txt >> iisquery.bat
echo echo ------Roles--------- ^>^> installed.txt >> iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[Web" services.txt') do @echo %%%%i ^>^> installed.txt >> iisquery.bat
echo echo ------Features----- ^>^> installed.txt >> iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[NET-Framework" services.txt') do @echo %%%%i ^>^> installed.txt >> iisquery.bat
call iisquery.bat
del roles.txt
del services.txt
echo Slide this page to the side to compare >> iis.txt
echo.		>> iis.txt
echo.		>> iis.txt
echo	1 Common Http Features:	>> iis.txt
echo	   Static Content	>> iis.txt
echo	   Default Document	>> iis.txt
echo	   Directory Browsing	>> iis.txt
echo	   HTTP Errors	>> iis.txt

echo	2 Application Development Features:	>> iis.txt
echo	   ASP.NET	>> iis.txt
echo	   .NET Extensibility	>> iis.txt
echo	   ISAPI Extensions	>> iis.txt
echo	   ISAPI Filters	>> iis.txt

echo	3 Health and Diagnostics:	>> iis.txt
echo	   HTTP Logging	>> iis.txt
echo	   Request Monitor	>> iis.txt

echo	4 Security:	>> iis.txt
echo	   Basic Authentication	>> iis.txt
echo	   Windows Authentication	>> iis.txt
echo	   Request Filtering	>> iis.txt

echo	5 Performance Features:	>> iis.txt
echo	   Static Content Compression	>> iis.txt

echo	6 Web Management Tools:	>> iis.txt
echo	   IIS Management Console	>> iis.txt
echo	   IIS6 Management Compatibility	>> iis.txt
echo            IIS 6 Metabase Compatibility  [Web-Metabase]    >> iis.txt
echo            IIS 6 WMI Compatibility  [Web-WMI]    >> iis.txt
echo            IIS 6 Scripting Tools  [Web-Lgcy-Scripting]    >> iis.txt
echo            IIS 6 Management Console  [Web-Lgcy-Mgmt-Console] >> iis.txt

echo ------Features-----  >> iis.txt
echo     .NET Framework 3.5.1 Features  [NET-Framework]    >> iis.txt
echo         .NET Framework 3.5.1  [NET-Framework-Core] >> iis.txt


echo.
echo Look for IIS Settings AND comparison lists 
start notepad iis.txt
start /wait notepad installed.txt 
del installed.txt
del iis.txt
del iisquery.bat

rem ---------------------
echo.
SET /P answer=Was IIS configured as expected? (y or n)
echo IIS was configured as expected: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check for Code 39 and Arial Unicode MS
start /wait control fonts
echo.
SET /P answer=Were Code 39 and Arial Unicode MS present? (y or n)
echo Code 39 and Arial Unicode MS were present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
start /wait winword.exe
SET /P answer=MSWord opens successfully? (y or n)
echo MSWord opens successfully: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Wait for Users and Groups Dialog
echo.
echo Local Group with Global Group, Global Group with susr, susr in Admin group and Global group in Distributed COM Users
lusrmgr.msc
echo.
SET /P answer=Are groups configured as expected? (y or n)
echo Groups are configured as expected: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
echo.

SET /P group=Please enter the ePMC_Users group name or 'unknown': (find susr in group)
net group /Domain %group%
echo.
SET /P answer=Is System User in the global group? (y or n)
echo System User is in the global group %group%: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check for IPv6 Interfaces  Look for addresses with ::
WMIC NICCONFIG WHERE IPENABLED=TRUE GET Description,IPADDRESS /FORMAT:LIST
SET /P answer=There are no IPv6 interfaces present? (y or n)
echo IPv6 interfaces were not present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


rem ----------------------
echo.
echo Wait for IE ESC Dialog
"C:\Windows\system32\rundll32.exe" C:\Windows\system32\iesetup.dll,IEShowHardeningDialog
SET /P answer=IE Enhanced Security is off? (y or n)
echo IE Enhanced Security is off: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem -----------------------
echo.
echo Wait for test.udl to be created on desktop
copy nul %userprofile%\Desktop\test.udl
pause
echo.
echo Check for Oracle Provider for OLE DB
C:\Windows\syswow64\rundll32.exe "C:\Program Files (x86)\Common Files\System\Ole DB\oledb32.dll",OpenDSLFile %userprofile%\Desktop\test.udl 
SET /P answer=Oracle Provider for OLE DB is present? (y or n)
echo Oracle Provider for OLE DB is present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
del %userprofile%\Desktop\test.udl


rem ----------------------------------
echo.
echo Checking for TNSNames.ora
for /f %%a in ('reg query hklm\software\wow6432node\oracle /f key^|FIND /I "KEY"') do (
set key=%%a
)
set DspName=Not Found
for /f "Tokens=2*" %%a in ('reg query %key% /V ORACLE_HOME^|Find "REG_SZ"') do (
set DspName=%%b
)
start /wait notepad %DspName%\network\admin\tnsnames.ora
SET /P answer=TNSNAMES.ORA file is present and configured? (y or n)
echo TNSNAMES.ORA file is present and configured: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check connection to the database.  The following script can be used to confirm.
echo SELECT * FROM NLS_DATABASE_PARAMETERS where parameter='NLS_CHARACTERSET';
echo SELECT * FROM dba_role_privs where granted_role='DBA';
echo column file_name format a50;
echo Select file_name, AUTOEXTENSIBLE from dba_data_files;
echo.
start sqlplus
SET /P answer=Able to connect to database? (y or n)
echo Able to connect to database: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem -------------------------------
echo.
echo Turn the firewall off
start /wait control firewall.cpl
SET /P answer=Firewalls are off? (y or n)
echo Firewalls are off: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo msgbox "Check for BIOVIA Software Installer Downloads!" > "%temp%\popup.vbs"
wscript.exe "%temp%\popup.vbs"
del %temp%\popup.vbs
SET /P answer=Installation media has been downloaded? (y or n)
echo Installation media has been downloaded: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


echo.
echo.
echo Review the sysinfo file and close when done.
start /wait notepad sysinfo.txt

ren sysinfo.txt lims_les_app_svr_%dt%.txt

echo All Done......LES v3.x and LIMS v4.2 APPLICATION SERVER PREREQUISITE CHECK
GOTO END


:BOTH12
rem ---------------------------------------------------------------------------------------------------------------------------------------
echo LES v3.x and LIMS v4.2 SP3 APPLICATION SERVER PREREQUISITE CHECK
echo LES v3.x and LIMS v4.2 SP3 APPLICATION SERVER PREREQUISITE CHECK >> sysinfo.txt
set dt=%date:~4,2%-%date:~7,2%-%date:~10,4%_%time:~0,2%%time:~3,2%
echo %dt% >> sysinfo.txt
echo. >> sysinfo.txt

wmic computersystem get name | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- CPU ------------------------------------ >> sysinfo.txt
wmic cpu get name | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- 4000000000 or greater of Memory  ------------------------------------ >> sysinfo.txt
wmic COMPUTERSYSTEM get TotalPhysicalMemory | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- 200000000000 or greater of FreeSpace  ------------------------------------ >> sysinfo.txt
wmic logicaldisk where drivetype=3 get Name,Size,Freespace | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- OS ------------------------------------ >> sysinfo.txt
echo English - United States    en   en-us      1252      409                    1033 >> sysinfo.txt
wmic os get ServicePackMajorVersion,Caption,OSArchitecture,locale, oslanguage, codeset | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt


echo ----------------------------------- Software Requirements ------------------------------------ >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Oracle Client 11g or higher 32-bit clients only-------------- >> sysinfo.txt
tnsping >> oracle.txt
FOR /F "tokens=5,7,8 delims= " %%i IN ('findstr /i /c:"Utility" oracle.txt') DO @echo %%j %%k %%i >> sysinfo.txt
echo. >> sysinfo.txt
echo. >> sysinfo.txt

echo.
echo ----- .Net v3.5 Feature installed?  ------------------------------------ >> sysinfo.txt
echo call C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Get-WindowsFeature ^>^> roles.txt > iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[X]" roles.txt') do @echo %%%%i ^>^> services.txt >> iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"NET-Framework-Core" services.txt') do @echo %%%%i ^>^> sysinfo.txt >> iisquery.bat
call iisquery.bat
del roles.txt
del services.txt 
del iisquery.bat
echo. >> sysinfo.txt
echo. >> sysinfo.txt

echo .NET Framework v4.0 SP1 or higher ------------------------------------ >> sysinfo.txt
echo call C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Get-WindowsFeature ^>^> roles.txt > iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[X]" roles.txt') do @echo %%%%i ^>^> services.txt >> iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"NET-Framework-45-Core" services.txt') do @echo %%%%i ^>^> sysinfo.txt >> iisquery.bat
call iisquery.bat
del roles.txt
del services.txt 
del iisquery.bat
echo. >> sysinfo.txt
echo. >> sysinfo.txt

echo Internet Explorer 9, 10 or 11 ------------------------------------ >> sysinfo.txt
set alias=Reg query "HKLM\SOFTWARE\Microsoft\Internet Explorer\Version Vector"
FOR /F "TOKENS=1,3 DELIMS=	 " %%A IN ('%alias%^|FIND /I "IE"') DO ECHO %%A %%B >> sysinfo.txt
echo. >> sysinfo.txt

echo Internet Information Server (IIS) ------------------------------------ >> sysinfo.txt
set alias2=Reg query "HKLM\Software\Microsoft\InetStp"
FOR /F "TOKENS=3,4 DELIMS=	 " %%A IN ('%alias2%^|FIND /I "VersionString"') DO ECHO %%A %%B >> sysinfo.txt
echo. >> sysinfo.txt

echo SAP Crystal Reports Runtime v13.0.3 or 13.0.12 32-bit ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%crystal%%'" get Name, Version | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Microsoft Word 2003, 2007, 2010, 2013(requires configuration) ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Microsoft%%Word%%'" get Name| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- MSXML3 8.20.8730.1 or higher ------------------------------------ >> sysinfo.txt
wmic datafile where name='c:\\windows\\system32\\msxml3.dll' get name, version | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Adobe Reader  9.4, 10 or 11 ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Adobe%%'" get Name, Version| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo Microsoft Silverlight v3 or higher ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Silverlight%%'" get Name, Version| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- System Cryptography FIPS 0=Disabled ------------------------------------------  >> sysinfo.txt
Reg query "HKLM\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- MSDTC Running? ------------------------------------ >> sysinfo.txt
wmic service where "Name like '%%MSDTC%%'" get Name, state  | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- 8dot3NameCreation Enabled? ------------------------------------ >> sysinfo.txt
echo.
echo Wait for 8dot3NameCreation
wmic logicaldisk where drivetype=3 get Name | find /v ""
echo.
SET /P drv=Please enter the drive letter (no colon) where LES will be installed: 
FSUTIL.EXE 8dot3name query %drv%: >> sysinfo.txt 
echo. >> sysinfo.txt
echo If disabled run this: fsutil 8dot3name set {DRV:} 0
echo. >> sysinfo.txt

echo ----- Accelrys Products Installed ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Accelrys%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
wmic product where "Name like '%%VelQuest%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
rem wmic product where "Name like '%%Accelrys%%'" get Name, Version >> sysinfo.txt 2>>&1
echo. >> sysinfo.txt

del oracle.txt



rem ----- IIS Roles and Features-----------------
echo call C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Get-WindowsFeature ^>^> roles.txt > iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[X]" roles.txt') do @echo %%%%i ^>^> services.txt >> iisquery.bat
echo echo ------Roles--------- ^>^> installed.txt >> iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"Web" services.txt') do @echo %%%%i ^>^> installed.txt >> iisquery.bat
echo echo ------Features----- ^>^> installed.txt >> iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"NET-Framework" services.txt') do @echo %%%%i ^>^> installed.txt >> iisquery.bat
call iisquery.bat
del roles.txt
del services.txt
echo	------Roles---------		>> iis_requirements.txt
echo	[X] Web Server (IIS)	Web-Server	>> iis_requirements.txt
echo	[X] Web Server	Web-WebServer	>> iis_requirements.txt
echo		[X] Common HTTP Features	Web-Common-Http	>> iis_requirements.txt
echo			[X] Default Document	Web-Default-Doc	>> iis_requirements.txt
echo			[X] Directory Browsing	Web-Dir-Browsing	>> iis_requirements.txt
echo			[X] HTTP Errors		Web-Http-Errors	>> iis_requirements.txt
echo			[X] Static Content	Web-Static-Content	>> iis_requirements.txt
echo		[X] Health and Diagnostics	Web-Health	>> iis_requirements.txt
echo			[X] HTTP Logging	Web-Http-Logging	>> iis_requirements.txt
echo			[X] Request Monitor	Web-Request-Monitor	>> iis_requirements.txt
echo		[X] Performance	Web-Performance	>> iis_requirements.txt
echo			[X] Static Content Compression	Web-Stat-Compression	>> iis_requirements.txt
echo		[X] Security		Web-Security	>> iis_requirements.txt
echo			[X] Request Filtering		Web-Filtering	>> iis_requirements.txt
echo			[X] Basic Authentication	Web-Basic-Auth	>> iis_requirements.txt
echo			[X] Windows Authentication	Web-Windows-Auth	>> iis_requirements.txt
echo		[X] Application Development	Web-App-Dev	>> iis_requirements.txt
echo			[X] .NET Extensibility 3.5	Web-Net-Ext	>> iis_requirements.txt
echo			[X] .NET Extensibility 4.5	Web-Net-Ext45	>> iis_requirements.txt
echo			[X] ASP		Web-ASP	>> iis_requirements.txt
echo			[X] ISAPI Extensions	Web-ISAPI-Ext	>> iis_requirements.txt
echo			[X] ISAPI Filters	Web-ISAPI-Filter	>> iis_requirements.txt
echo	[X] Management Tools	Web-Mgmt-Tools	>> iis_requirements.txt
echo		[X] IIS Management Console	Web-Mgmt-Console	>> iis_requirements.txt
echo			[X] IIS 6 Management Compatibility	Web-Mgmt-Compat	>> iis_requirements.txt
echo			[X] IIS 6 Metabase Compatibility	Web-Metabase	>> iis_requirements.txt
echo	------Features-----		>> iis_requirements.txt
echo	[X] .NET Framework 3.5 Features	NET-Framework-Features	>> iis_requirements.txt
echo.	[X] .NET Framework 3.5 (includes .NET 2.0 and 3.0)	NET-Framework-Core	>> iis_requirements.txt
echo	[X] .NET Framework 4.5 Features	NET-Framework-45-Fea...	>> iis_requirements.txt
echo.	[X] .NET Framework 4.5	NET-Framework-45-Core	>> iis_requirements.txt
echo.	[X] ASP.NET 4.5	NET-Framework-45-ASPNET	>> iis_requirements.txt
echo.			>> iis_requirements.txt

echo Look for IIS Settings AND comparison lists 
start notepad iis_requirements.txt
start /wait notepad installed.txt 
del installed.txt
del iis_requirements.txt
del iisquery.bat

rem ---------------------
echo.
SET /P answer=Was IIS configured as expected? (y or n)
echo IIS was configured as expected: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check for Code 39 and Arial Unicode MS
start /wait control fonts
echo.
SET /P answer=Were Code 39 and Arial Unicode MS present? (y or n)
echo Code 39 and Arial Unicode MS were present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
start /wait winword.exe
SET /P answer=MSWord opens successfully? (y or n)
echo MSWord opens successfully: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Wait for Users and Groups Dialog
echo.
echo Local Group with Global Group, Global Group with susr, susr in Admin group and Global group in Distributed COM Users
lusrmgr.msc
echo.
SET /P answer=Are groups configured as expected? (y or n)
echo Groups are configured as expected: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
echo.

SET /P group=Please enter the ePMC_Users group name or 'unknown': (find susr in group)
net group /Domain %group%
echo.
SET /P answer=Is System User in the global group? (y or n)
echo System User is in the global group %group%: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check for IPv6 Interfaces  Look for addresses with ::
WMIC NICCONFIG WHERE IPENABLED=TRUE GET Description,IPADDRESS /FORMAT:LIST
SET /P answer=There are no IPv6 interfaces present? (y or n)
echo IPv6 interfaces were not present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


rem ----------------------
echo.
echo Wait for IE ESC Dialog
"C:\Windows\system32\rundll32.exe" C:\Windows\system32\iesetup.dll,IEShowHardeningDialog
SET /P answer=IE Enhanced Security is off? (y or n)
echo IE Enhanced Security is off: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem -----------------------
echo.
echo Wait for test.udl to be created on desktop
copy nul %userprofile%\Desktop\test.udl
pause
echo.
echo Check for Oracle Provider for OLE DB
C:\Windows\syswow64\rundll32.exe "C:\Program Files (x86)\Common Files\System\Ole DB\oledb32.dll",OpenDSLFile %userprofile%\Desktop\test.udl 
SET /P answer=Oracle Provider for OLE DB is present? (y or n)
echo Oracle Provider for OLE DB is present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
del %userprofile%\Desktop\test.udl


rem ----------------------------------
echo.
echo Checking for TNSNames.ora
for /f %%a in ('reg query hklm\software\wow6432node\oracle /f key^|FIND /I "KEY"') do (
set key=%%a
)
set DspName=Not Found
for /f "Tokens=2*" %%a in ('reg query %key% /V ORACLE_HOME^|Find "REG_SZ"') do (
set DspName=%%b
)
start /wait notepad %DspName%\network\admin\tnsnames.ora
SET /P answer=TNSNAMES.ORA file is present and configured? (y or n)
echo TNSNAMES.ORA file is present and configured: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check connection to the database.  The following script can be used to confirm.
echo SELECT * FROM NLS_DATABASE_PARAMETERS where parameter='NLS_CHARACTERSET';
echo SELECT * FROM dba_role_privs where granted_role='DBA';
echo column file_name format a50;
echo Select file_name, AUTOEXTENSIBLE from dba_data_files;
echo.
start sqlplus
SET /P answer=Able to connect to database? (y or n)
echo Able to connect to database: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem -------------------------------
echo.
echo Turn the firewall off
start /wait control firewall.cpl
SET /P answer=Firewalls are off? (y or n)
echo Firewalls are off: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo msgbox "Check for BIOVIA Software Installer Downloads!" > "%temp%\popup.vbs"
wscript.exe "%temp%\popup.vbs"
del %temp%\popup.vbs
SET /P answer=Installation media has been downloaded? (y or n)
echo Installation media has been downloaded: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


echo.
echo.
echo Review the sysinfo file and close when done.
start /wait notepad sysinfo.txt

ren sysinfo.txt lims_les_app_svr_%dt%.txt

echo All Done......LES v3.x and LIMS v4.2 SP3 APPLICATION SERVER PREREQUISITE CHECK
GOTO END


:LES12
rem ---------------------------------------------------------------------------------------------------------------------------------------
echo LES v3.5 or 3.6 APPLICATION SERVER PREREQUISITE CHECK
echo LES v3.5 or 3.6 APPLICATION SERVER PREREQUISITE CHECK >> sysinfo.txt
echo. >> sysinfo.txt
set dt=%date:~4,2%-%date:~7,2%-%date:~10,4%_%time:~0,2%%time:~3,2%
echo %dt% >> sysinfo.txt
echo. >> sysinfo.txt

wmic computersystem get name | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- CPU ------------------------------------ >> sysinfo.txt
wmic cpu get name | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- 4000000000 or greater of Memory  ------------------------------------ >> sysinfo.txt
wmic COMPUTERSYSTEM get TotalPhysicalMemory | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- 200000000000 or greater of FreeSpace  ------------------------------------ >> sysinfo.txt
wmic logicaldisk where drivetype=3 get Name,Size,Freespace | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- OS ------------------------------------ >> sysinfo.txt
echo English - United States    en   en-us      1252      409                    1033 >> sysinfo.txt
wmic os get ServicePackMajorVersion,Caption,OSArchitecture,locale, oslanguage, codeset | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt


echo ----------------------------------- Software Requirements ------------------------------------ >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Oracle Client 11g or higher 32-bit clients only-------------- >> sysinfo.txt
tnsping >> oracle.txt
FOR /F "tokens=5,7,8 delims= " %%i IN ('findstr /i /c:"Utility" oracle.txt') DO @echo %%j %%k %%i >> sysinfo.txt
echo. >> sysinfo.txt
echo. >> sysinfo.txt

echo.
echo ----- .Net v3.5 Feature installed?  ------------------------------------ >> sysinfo.txt
echo call C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Get-WindowsFeature ^>^> roles.txt > iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[X]" roles.txt') do @echo %%%%i ^>^> services.txt >> iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"NET-Framework-Core" services.txt') do @echo %%%%i ^>^> sysinfo.txt >> iisquery.bat
call iisquery.bat
del roles.txt
del services.txt 
del iisquery.bat
echo. >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Microsoft Word 2003, 2007, 2010, 2013 ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Microsoft%%Word%%'" get Name| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- MSXML3 8.20.8730.1 or higher ------------------------------------ >> sysinfo.txt
wmic datafile where name='c:\\windows\\system32\\msxml3.dll' get name, version | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Adobe Reader  9, 10 or 11 ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Adobe%%'" get Name, Version| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- System Cryptography FIPS 0=Disabled ------------------------------------------  >> sysinfo.txt
Reg query "HKLM\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- MSDTC Running? ------------------------------------ >> sysinfo.txt
wmic service where "Name like '%%MSDTC%%'" get Name, state  | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- 8dot3NameCreation Enabled? ------------------------------------ >> sysinfo.txt
echo.
echo Wait for 8dot3NameCreation
wmic logicaldisk where drivetype=3 get Name | find /v ""
echo.
SET /P drv=Please enter the drive letter (no colon) where LES will be installed: 
FSUTIL.EXE 8dot3name query %drv%: >> sysinfo.txt 
echo. >> sysinfo.txt
echo If disabled run this: fsutil 8dot3name set {DRV:} 0
echo. >> sysinfo.txt

echo ----- Accelrys Products Installed ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Accelrys%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
wmic product where "Name like '%%VelQuest%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
rem wmic product where "Name like '%%Accelrys%%'" get Name, Version >> sysinfo.txt 2>>&1
echo. >> sysinfo.txt

del oracle.txt


echo ----- wait for Word and Excel DCOM Settings  ------------------------------------ 
c:\windows\syswow64\mmc comexp.msc /32
echo.
SET /P answer=Word and Excel DCOM Settings are visible? (y or n)
echo Word and Excel DCOM Settings are visible: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Wait for Users and Groups Dialog
echo.
echo Local Group with Global Group, Global Group with susr, susr in Admin group and Global group in Distributed COM Users
lusrmgr.msc
echo.
SET /P answer=Are groups configured as expected? (y or n)
echo Groups are configured as expected: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
echo.

SET /P group=Please enter the ePMC_Users group name or 'unknown': (find susr in group)
net group /Domain %group%
echo.
SET /P answer=Is System User in the global group? (y or n)
echo System User is in the global group %group%: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


rem -----------------------
echo.
echo Wait for test.udl to be created on desktop
copy nul %userprofile%\Desktop\test.udl
pause
echo.
echo Check for Oracle Provider for OLE DB
C:\Windows\syswow64\rundll32.exe "C:\Program Files (x86)\Common Files\System\Ole DB\oledb32.dll",OpenDSLFile %userprofile%\Desktop\test.udl 
SET /P answer=Oracle Provider for OLE DB is present? (y or n)
echo Oracle Provider for OLE DB is present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
del %userprofile%\Desktop\test.udl


rem ----------------------------------
echo.
echo Checking for TNSNames.ora
for /f %%a in ('reg query hklm\software\wow6432node\oracle /f key^|FIND /I "KEY"') do (
set key=%%a
)
set DspName=Not Found
for /f "Tokens=2*" %%a in ('reg query %key% /V ORACLE_HOME^|Find "REG_SZ"') do (
set DspName=%%b
)
start /wait notepad %DspName%\network\admin\tnsnames.ora
SET /P answer=TNSNAMES.ORA file is present and configured? (y or n)
echo TNSNAMES.ORA file is present and configured: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check connection to the database.  The following script can be used to confirm.
echo SELECT * FROM NLS_DATABASE_PARAMETERS where parameter='NLS_CHARACTERSET';
echo SELECT * FROM dba_role_privs where granted_role='DBA';
echo column file_name format a50;
echo Select file_name, AUTOEXTENSIBLE from dba_data_files;
echo.
start sqlplus
SET /P answer=Able to connect to database? (y or n)
echo Able to connect to database: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
start /wait winword.exe
SET /P answer=MSWord opens successfully? (y or n)
echo MSWord opens successfully: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check for IPv6 Interfaces  Look for addresses with ::
WMIC NICCONFIG WHERE IPENABLED=TRUE GET Description,IPADDRESS /FORMAT:LIST
SET /P answer=There are no IPv6 interfaces present? (y or n)
echo IPv6 interfaces were not present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


rem -------------------------------
echo.
echo Turn the firewall off
start /wait control firewall.cpl
SET /P answer=Firewalls are off? (y or n)
echo Firewalls are off: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo msgbox "Check for BIOVIA Software Installer Downloads!" > "%temp%\popup.vbs"
wscript.exe "%temp%\popup.vbs"
del %temp%\popup.vbs
SET /P answer=Installation media has been downloaded? (y or n)
echo Installation media has been downloaded: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

echo.
echo.
echo Review the sysinfo file and close when done.
start /wait notepad sysinfo.txt

echo All Done......
ren sysinfo.txt les_app_svr_%dt%.txt

GOTO END



:LIMS12
rem ----------------------------------------------------------------------------------------------------------------------------------
echo LIMS v4.2 SP3 APPLICATION SERVER (2012) PREREQUISITE CHECK
echo LIMS v4.2 SP3 APPLICATION SERVER (2012) PREREQUISITE CHECK >> sysinfo.txt
echo. >> sysinfo.txt
set dt=%date:~4,2%-%date:~7,2%-%date:~10,4%_%time:~0,2%%time:~3,2%
echo %dt% >> sysinfo.txt
echo. >> sysinfo.txt

wmic computersystem get name |find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- CPU ------------------------------------ >> sysinfo.txt
wmic cpu get name | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- 4000000000 or greater of Memory  ------------------------------------ >> sysinfo.txt
wmic COMPUTERSYSTEM get TotalPhysicalMemory | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- 200000000000 or greater of FreeSpace  ------------------------------------ >> sysinfo.txt
wmic logicaldisk where drivetype=3 get Name,Size,Freespace | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- OS ------------------------------------ >> sysinfo.txt
echo English - United States    en   en-us      1252      409                    1033 >> sysinfo.txt
wmic os get ServicePackMajorVersion,Caption,OSArchitecture,locale, oslanguage, codeset | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt


echo ----------------------------------- Software Requirements ------------------------------------ >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Oracle Client 11g or higher 32-bit clients only-------------- >> sysinfo.txt
tnsping >> oracle.txt
FOR /F "tokens=5,7,8 delims= " %%i IN ('findstr /i /c:"Utility" oracle.txt') DO @echo %%j %%k %%i >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- .NET Framework v4.0 SP1 or higher ------------------------------------ >> sysinfo.txt
echo call C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Get-WindowsFeature ^>^> roles.txt > iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[X]" roles.txt') do @echo %%%%i ^>^> services.txt >> iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"NET-Framework-45-Core" services.txt') do @echo %%%%i ^>^> sysinfo.txt >> iisquery.bat
call iisquery.bat
del roles.txt
del services.txt 
del iisquery.bat
echo. >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Internet Explorer 9, 10, 11  ------------------------------------ >> sysinfo.txt
set alias=Reg query "HKLM\SOFTWARE\Microsoft\Internet Explorer\Version Vector"
FOR /F "TOKENS=1,3 DELIMS=	 " %%A IN ('%alias%^|FIND /I "IE"') DO ECHO %%A %%B >> sysinfo.txt
echo. >> sysinfo.txt

echo Internet Information Server (IIS) ------------------------------------ >> sysinfo.txt
set alias2=Reg query "HKLM\Software\Microsoft\InetStp"
FOR /F "TOKENS=3,4 DELIMS=	 " %%A IN ('%alias2%^|FIND /I "VersionString"') DO ECHO %%A %%B >> sysinfo.txt
echo. >> sysinfo.txt

echo SAP Crystal Reports Runtime v13.0.3 32-bit ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%crystal%%'" get Name, Version | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo Adobe Reader  9.4 or higher ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Adobe%%'" get Name, Version| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo Microsoft Silverlight v3 or higher ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Silverlight%%'" get Name, Version| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo System Cryptography FIPS 0=Disabled ------------------------------------------  >> sysinfo.txt
Reg query "HKLM\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" >> sysinfo.txt
echo. >> sysinfo.txt

echo BIOVIA Products Installed ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Accelrys%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
wmic product where "Name like '%%VelQuest%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
rem wmic product where "Name like '%%Accelrys%%'" get Name, Version >> sysinfo.txt 2>>&1
echo. >> sysinfo.txt

del oracle.txt


rem -----IIS Roles and Features-----------------
echo call C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Get-WindowsFeature ^>^> roles.txt > iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[X]" roles.txt') do @echo %%%%i ^>^> services.txt >> iisquery.bat
echo echo ------Roles--------- ^>^> installed.txt >> iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"Web" services.txt') do @echo %%%%i ^>^> installed.txt >> iisquery.bat
echo echo ------Features----- ^>^> installed.txt >> iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"NET-Framework" services.txt') do @echo %%%%i ^>^> installed.txt >> iisquery.bat
call iisquery.bat
del roles.txt
del services.txt
echo	------Roles---------		>> iis_requirements.txt
echo	[X] Web Server (IIS)	Web-Server	>> iis_requirements.txt
echo	[X] Web Server	Web-WebServer	>> iis_requirements.txt
echo		[X] Common HTTP Features	Web-Common-Http	>> iis_requirements.txt
echo			[X] Default Document	Web-Default-Doc	>> iis_requirements.txt
echo			[X] Directory Browsing	Web-Dir-Browsing	>> iis_requirements.txt
echo			[X] HTTP Errors		Web-Http-Errors	>> iis_requirements.txt
echo			[X] Static Content	Web-Static-Content	>> iis_requirements.txt
echo		[X] Health and Diagnostics	Web-Health	>> iis_requirements.txt
echo			[X] HTTP Logging	Web-Http-Logging	>> iis_requirements.txt
echo			[X] Request Monitor	Web-Request-Monitor	>> iis_requirements.txt
echo		[X] Performance	Web-Performance	>> iis_requirements.txt
echo			[X] Static Content Compression	Web-Stat-Compression	>> iis_requirements.txt
echo		[X] Security		Web-Security	>> iis_requirements.txt
echo			[X] Request Filtering		Web-Filtering	>> iis_requirements.txt
echo			[X] Basic Authentication	Web-Basic-Auth	>> iis_requirements.txt
echo			[X] Windows Authentication	Web-Windows-Auth	>> iis_requirements.txt
echo		[X] Application Development	Web-App-Dev	>> iis_requirements.txt
echo			[X] .NET Extensibility 3.5	Web-Net-Ext	>> iis_requirements.txt
echo			[X] .NET Extensibility 4.5	Web-Net-Ext45	>> iis_requirements.txt
echo			[X] ASP		Web-ASP	>> iis_requirements.txt
echo			[X] ISAPI Extensions	Web-ISAPI-Ext	>> iis_requirements.txt
echo			[X] ISAPI Filters	Web-ISAPI-Filter	>> iis_requirements.txt
echo	[X] Management Tools	Web-Mgmt-Tools	>> iis_requirements.txt
echo		[X] IIS Management Console	Web-Mgmt-Console	>> iis_requirements.txt
echo			[X] IIS 6 Management Compatibility	Web-Mgmt-Compat	>> iis_requirements.txt
echo			[X] IIS 6 Metabase Compatibility	Web-Metabase	>> iis_requirements.txt
echo	------Features-----		>> iis_requirements.txt
echo	[X] .NET Framework 3.5 Features	NET-Framework-Features	>> iis_requirements.txt
echo.	[X] .NET Framework 3.5 (includes .NET 2.0 and 3.0)	NET-Framework-Core	>> iis_requirements.txt
echo	[X] .NET Framework 4.5 Features	NET-Framework-45-Fea...	>> iis_requirements.txt
echo.	[X] .NET Framework 4.5	NET-Framework-45-Core	>> iis_requirements.txt
echo.	[X] ASP.NET 4.5	NET-Framework-45-ASPNET	>> iis_requirements.txt
echo.			>> iis_requirements.txt

echo ----- Look for IIS Settings AND comparison lists 
start notepad iis_requirements.txt
start /wait notepad installed.txt 
del installed.txt
del iis_requirements.txt
del iisquery.bat

rem ---------------------
echo.
SET /P answer=Was IIS configured as expected? (y or n)
echo IIS was configured as expected: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check for Code 39 and Arial Unicode MS
start /wait control fonts
echo.
SET /P answer=Were Code 39 and Arial Unicode MS present? (y or n)
echo Code 39 and Arial Unicode MS were present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check for IPv6 Interfaces  Look for addresses with ::
WMIC NICCONFIG WHERE IPENABLED=TRUE GET Description,IPADDRESS /FORMAT:LIST
SET /P answer=There are no IPv6 interfaces present? (y or n)
echo IPv6 interfaces were not present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


rem ----------------------
echo.
echo Wait for IE ESC Dialog
"C:\Windows\system32\rundll32.exe" C:\Windows\system32\iesetup.dll,IEShowHardeningDialog
SET /P answer=IE Enhanced Security is off? (y or n)
echo IE Enhanced Security is off: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem -----------------------
echo.
echo Wait for test.udl to be created on desktop
copy nul %userprofile%\Desktop\test.udl
pause
echo.
echo Check for Oracle Provider for OLE DB
C:\Windows\syswow64\rundll32.exe "C:\Program Files (x86)\Common Files\System\Ole DB\oledb32.dll",OpenDSLFile %userprofile%\Desktop\test.udl 
SET /P answer=Oracle Provider for OLE DB is present? (y or n)
echo Oracle Provider for OLE DB is present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
del %userprofile%\Desktop\test.udl


rem ----------------------------------
echo.
echo Checking for TNSNames.ora
for /f %%a in ('reg query hklm\software\wow6432node\oracle /f key^|FIND /I "KEY"') do (
set key=%%a
)
set DspName=Not Found
for /f "Tokens=2*" %%a in ('reg query %key% /V ORACLE_HOME^|Find "REG_SZ"') do (
set DspName=%%b
)
start /wait notepad %DspName%\network\admin\tnsnames.ora
SET /P answer=TNSNAMES.ORA file is present and configured? (y or n)
echo TNSNAMES.ORA file is present and configured: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check connection to the database.  The following script can be used to confirm.
echo SELECT * FROM NLS_DATABASE_PARAMETERS where parameter='NLS_CHARACTERSET';
echo SELECT * FROM dba_role_privs where granted_role='DBA';
echo column file_name format a50;
echo Select file_name, AUTOEXTENSIBLE from dba_data_files;
echo.
start sqlplus
SET /P answer=Able to connect to database? (y or n)
echo Able to connect to database: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem -------------------------------
echo.
echo Turn the firewall off
start /wait control firewall.cpl
SET /P answer=Firewalls are off? (y or n)
echo Firewalls are off: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo msgbox "Check for BIOVIA Software Installer Downloads!" > "%temp%\popup.vbs"
wscript.exe "%temp%\popup.vbs"
del %temp%\popup.vbs
SET /P answer=Installation media has been downloaded? (y or n)
echo Installation media has been downloaded: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


echo.
echo.
echo Review the sysinfo file and close when done.
start /wait notepad sysinfo.txt

ren sysinfo.txt lims_app_svr_%dt%.txt

echo All Done......
GOTO END




:CLIENT12
rem --------------------------------------------------------------------------------------------------------------------------------------
echo LES v3.5 or 3.6 CLIENT SERVER PREREQUISITE CHECK
echo LES v3.5 or 3.6 CLIENT SERVER PREREQUISITE CHECK >> sysinfo.txt
echo. >> sysinfo.txt
set dt=%date:~4,2%-%date:~7,2%-%date:~10,4%_%time:~0,2%%time:~3,2%
echo %dt% >> sysinfo.txt
echo. >> sysinfo.txt

wmic computersystem get name |find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- CPU ------------------------------------ >> sysinfo.txt
wmic cpu get name | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- 4000000000 or greater of Memory  ------------------------------------ >> sysinfo.txt
wmic COMPUTERSYSTEM get TotalPhysicalMemory | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- 200000000000 or greater of FreeSpace  ------------------------------------ >> sysinfo.txt
wmic logicaldisk where drivetype=3 get Name,Size,Freespace | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- OS ------------------------------------ >> sysinfo.txt
echo English - United States    en   en-us      1252      409                    1033 >> sysinfo.txt
wmic os get ServicePackMajorVersion,Caption,OSArchitecture,locale, oslanguage, codeset | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt


echo ----------------------------------- Software Requirements ------------------------------------ >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Oracle Client 11g or higher 32-bit clients only-------------- >> sysinfo.txt
tnsping >> oracle.txt
FOR /F "tokens=5,7,8 delims= " %%i IN ('findstr /i /c:"Utility" oracle.txt') DO @echo %%j %%k %%i >> sysinfo.txt
echo. >> sysinfo.txt

echo.
echo ----- .Net v3.5 Feature installed?  ------------------------------------ >> sysinfo.txt
echo call C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Get-WindowsFeature ^>^> roles.txt > iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"[X]" roles.txt') do @echo %%%%i ^>^> services.txt >> iisquery.bat
echo for /f "Tokens=1,2 Delims=" %%%%i in ('findstr /i /c:"NET-Framework-Core" services.txt') do @echo %%%%i ^>^> sysinfo.txt >> iisquery.bat
call iisquery.bat
del roles.txt
del services.txt 
del iisquery.bat
echo. >> sysinfo.txt
echo. >> sysinfo.txt


echo ----- MSXML3 8.20.8730.1 or higher ------------------------------------ >> sysinfo.txt
wmic datafile where name='c:\\windows\\system32\\msxml3.dll' get name, version | find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Microsoft Word   Any Version------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Microsoft%%Word%%'" get Name| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Microsoft Excel   Any Version------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Microsoft%%Excel%%'" get Name| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- Adobe Reader  Any Version------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Adobe%%'" get Name, Version| find /v "" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- System Cryptography FIPS 0=Disabled ------------------------------------------  >> sysinfo.txt
Reg query "HKLM\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" >> sysinfo.txt
echo. >> sysinfo.txt

echo ----- BIOVIA Products Installed ------------------------------------ >> sysinfo.txt
wmic product where "Name like '%%Accelrys%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
wmic product where "Name like '%%VelQuest%%'" get Name, Version| find /v "" >> sysinfo.txt 2>>&1
rem wmic product where "Name like '%%Accelrys%%'" get Name, Version >> sysinfo.txt 2>>&1
echo. >> sysinfo.txt

del oracle.txt

rem -----------------------
echo.
echo Wait for test.udl to be created on desktop
copy nul %userprofile%\Desktop\test.udl
pause
echo.
echo Check for Oracle Provider for OLE DB
C:\Windows\syswow64\rundll32.exe "C:\Program Files (x86)\Common Files\System\Ole DB\oledb32.dll",OpenDSLFile %userprofile%\Desktop\test.udl 
SET /P answer=Oracle Provider for OLE DB is present? (y or n)
echo Oracle Provider for OLE DB is present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
del %userprofile%\Desktop\test.udl


rem ----------------------------------
echo.
echo Checking for TNSNames.ora
for /f %%a in ('reg query hklm\software\wow6432node\oracle /f key^|FIND /I "KEY"') do (
set key=%%a
)
set DspName=Not Found
for /f "Tokens=2*" %%a in ('reg query %key% /V ORACLE_HOME^|Find "REG_SZ"') do (
set DspName=%%b
)
start /wait notepad %DspName%\network\admin\tnsnames.ora
SET /P answer=TNSNAMES.ORA file is present and configured? (y or n)
echo TNSNAMES.ORA file is present and configured: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
echo Check connection to the database.  The following script can be used to confirm.
echo SELECT * FROM NLS_DATABASE_PARAMETERS where parameter='NLS_CHARACTERSET';
echo SELECT * FROM dba_role_privs where granted_role='DBA';
echo column file_name format a50;
echo Select file_name, AUTOEXTENSIBLE from dba_data_files;
echo.
start sqlplus
SET /P answer=Able to connect to database? (y or n)
echo Able to connect to database: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


rem -----------------------
echo.
echo Verify file associations for doc dat and pdf
copy nul %userprofile%\Desktop\test.doc
copy nul %userprofile%\Desktop\test.dat
copy nul %userprofile%\Desktop\test.pdf
rem --------------------
rem create reg file to make dat assoc. in HKLM
echo.
echo Double click dat.reg to set .dat association for all users
echo.
echo	Windows Registry Editor Version 5.00	>> dat.reg
echo.		>> dat.reg
echo.		>> dat.reg
echo	[HKEY_LOCAL_MACHINE\Software\Classes\.dat]	>> dat.reg
echo	@="dat_auto_file"	>> dat.reg
echo.		>> dat.reg
echo	[HKEY_LOCAL_MACHINE\Software\Classes\dat_auto_file]	>> dat.reg
echo	@=""	>> dat.reg
echo.		>> dat.reg
echo	[HKEY_LOCAL_MACHINE\Software\Classes\dat_auto_file\shell]	>> dat.reg
echo.		>> dat.reg
echo	[HKEY_LOCAL_MACHINE\Software\Classes\dat_auto_file\shell\edit]	>> dat.reg
echo.		>> dat.reg
echo	[HKEY_LOCAL_MACHINE\Software\Classes\dat_auto_file\shell\edit\command]	>> dat.reg
echo	@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,4e,00,4f,00,54,00,45,00,50,00,41,00,44,00,2e,00,45,00,58,00,45,00,20,00,25,00,31,00,00,00	>> dat.reg
echo.		>> dat.reg
echo	[HKEY_LOCAL_MACHINE\Software\Classes\dat_auto_file\shell\open]	>> dat.reg
echo.		>> dat.reg
echo	[HKEY_LOCAL_MACHINE\Software\Classes\dat_auto_file\shell\open\command]	>> dat.reg
echo	@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,4e,00,4f,00,54,00,45,00,50,00,41,00,44,00,2e,00,45,00,58,00,45,00,20,00,25,00,31,00,00,00	>> dat.reg
rem -----------------  
pause
del test.doc
del test.dat
del test.pdf
del dat.reg

SET /P answer=File associations set? (y or n)
echo File associations set: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

rem ----------------------
echo.
start /wait winword.exe
SET /P answer=MSWord opens successfully? (y or n)
echo MSWord opens successfully: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


rem ----------------------
echo.
start /wait excel.exe
SET /P answer=MSExcel opens successfully? (y or n)
echo MSExcel opens successfully: %answer% >> sysinfo.txt
echo. >> sysinfo.txt
 

rem ----------------------
echo.
echo Check for IPv6 Interfaces  Look for addresses with ::
WMIC NICCONFIG WHERE IPENABLED=TRUE GET Description,IPADDRESS /FORMAT:LIST
SET /P answer=There are no IPv6 interfaces present? (y or n)
echo IPv6 interfaces were not present: %answer% >> sysinfo.txt
echo. >> sysinfo.txt


rem -------------------------------
echo.
echo Turn the firewall off
start /wait control firewall.cpl
SET /P answer=Firewalls are off? (y or n)
echo Firewalls are off: %answer% >> sysinfo.txt
echo. >> sysinfo.txt

echo.
echo.
echo Review the sysinfo file and close when done.
start /wait notepad sysinfo.txt

echo All Done......
ren sysinfo.txt les_app_svr_%dt%.txt


GOTO END



:END