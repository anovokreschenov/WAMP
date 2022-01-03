@echo off

net session >nul 2>&1

if ERRORLEVEL 1 (
	powershell -Command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs" & goto :eof
)

setlocal

pushd %~dp0

set PATH=%CD%\bin\apache\bin;%CD%\bin\mysql\bin;%PATH%

call :check_service_running "wamp_httpd"

if not ERRORLEVEL 1 (
	call :execute "Stopping the HTTPD service" "net stop wamp_httpd" || goto quit
)

call :check_service_installed "wamp_httpd"

if not ERRORLEVEL 1 (
	call :execute "Uninstalling the HTTPD service" "httpd -n wamp_httpd -k uninstall" || goto quit
)

call :check_service_running "wamp_mysql"

if not ERRORLEVEL 1 (
	call :execute "Stopping the MySQL service" "net stop wamp_mysql" || goto quit
)

call :check_service_installed "wamp_mysql"

if not ERRORLEVEL 1 (
	call :execute "Uninstalling the MySQL service" "mysqld --remove wamp_mysql" || goto quit
)

:quit

popd

echo %CMDCMDLINE% | find "%~nx0" >nul 2>&1 && pause

goto :eof

:check_service_installed

sc query state=all | find "SERVICE_NAME: %~1" >nul 2>&1 & goto :eof

:check_service_running

sc query %~1 | find "RUNNING" >nul 2>&1 & goto :eof

:execute

echo. | set /p v="%~1..." & ((%~2 >nul 2>&1 && echo SUCCESS) || echo FAILED) & goto :eof
