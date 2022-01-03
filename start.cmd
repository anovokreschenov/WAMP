@echo off

net session >nul 2>&1

if ERRORLEVEL 1 (
	powershell -Command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs" & goto :eof
)

setlocal

pushd %~dp0

set PATH=%CD%\bin\apache\bin;%CD%\bin\mysql\bin;%PATH%

if not exist data\mysql\ibdata1 (
	set MYSQL_PASSWORD_REQUIRED=1 & call :execute "Initializing the MySQL database" "mysqld --defaults-file=%CD%\conf\mysql\my.cnf --initialize-insecure --console" || goto quit
)

call :check_service_installed "wamp_mysql"

if ERRORLEVEL 1 (
	call :execute "Installing the MySQL service" "mysqld --install wamp_mysql --defaults-file=%CD%\conf\mysql\my.cnf" || goto quit
)

call :check_service_running "wamp_mysql"

if ERRORLEVEL 1 (
	call :execute "Starting the MySQL service" "net start wamp_mysql" || goto quit
)

if defined MYSQL_PASSWORD_REQUIRED (
	call :execute "Updating the MySQL 'root' password" "echo ALTER USER 'root'@'localhost' IDENTIFIED BY 'root'; | mysql --defaults-file=%CD%\conf\mysql\my.cnf -u root --skip-password" || goto quit
)

call :check_service_installed "wamp_httpd"

if ERRORLEVEL 1 (
	call :execute "Installing the HTTPD service" "httpd -n wamp_httpd -k install -f %CD%\conf\apache\httpd.conf" || goto quit
)

call :check_service_running "wamp_httpd"

if ERRORLEVEL 1 (
	call :execute "Starting the HTTPD service" "net start wamp_httpd" || goto quit
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
