@ECHO OFF & CD /D %~DP0
::this use to get administrator auth
>NUL 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\Getadmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%1", "", "runas", 1 >> "%TEMP%\Getadmin.vbs"
    "%TEMP%\Getadmin.vbs"
    DEL /f /q "%TEMP%\Getadmin.vbs" 2>NUL
    Exit /b
)
::get administrator auth end

::get input params.if the first param is yes,this script will exit at finish
set slient=%1%

::wsl -l -v
set linuxName=openSUSE-Leap-15-1

copy getIp.sh \\wsl$\openSUSE-Leap-15-1\tmp > nul

wsl -d openSUSE-Leap-15-1 -u root chmod +x /tmp/getIp.sh

for /F %%i in ('wsl -d %linuxName% -u root /tmp/getIp.sh') do ( set wslIp=%%i)

echo WSLIP:%wslIp%

::Ports format:
::Host,WSL;Host,WSL
::for example
::if you want to forward your host port 80 to wsl port 8080 and forward host port 81 to wsl port 8081,update like this:
::set forwardPorts=80,8080;81,8081

set forwardPorts=22,22
::;80,80;3306,3306;6379,6379;9300,9300

::You can change the listenIp to your ip config to listen to a specific address
set listenIp=192.168.128.89

:SplitAndForward
for /f "tokens=1,* delims=;" %%i in ("%forwardPorts%") do (
	for /f "tokens=1,2 delims=," %%m in ("%%i") do (
		echo forward %listenIp%:%%m to %wslIp%:%%n
		echo netsh interface portproxy add v4tov4 listenport=%%m listenaddress=%listenIp% connectport=%%n connectaddress=%wslIp% 
		netsh interface portproxy add v4tov4 listenport=%%m listenaddress=%listenIp% connectport=%%n connectaddress=%wslIp% 
	)
	set forwardPorts=%%j
	if not "%forwardPorts%"=="" goto SplitAndForward
)

netsh interface portproxy show all

pause
exit 

if "%slient%"=="yes" start ת��WSL�����˿ڵ�����.vbs & exit
pause
