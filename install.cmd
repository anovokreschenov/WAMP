@echo off

net session >nul 2>&1

if ERRORLEVEL 1 (
	powershell -Command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs" & goto :eof
)

setlocal

pushd %~dp0

for /d %%d in (bin,data,conf,logs,pids,root,temp) do (
	if not exist %%d md %%d >nul 2>&1
)

if not exist bin\apache\bin\httpd.exe (
	if exist bin\apache rd /q /s bin\apache >nul 2>&1
	(
		echo. | set /p v="Installing Apache 2.4.54..."^
		&& powershell -Command "$progressPreference = 'silentlyContinue'; Invoke-WebRequest -Method Get -Uri 'https://home.apache.org/~steffenal/VC15/binaries/httpd-2.4.54-win64-VC15.zip' -OutFile '%CD%\temp\apache.zip';" >nul 2>&1^
		&& powershell -Command "$progressPreference = 'silentlyContinue'; Expand-Archive -Path '%CD%\temp\apache.zip' -DestinationPath '%CD%\temp\apache' -Force;" >nul 2>&1^
		&& move temp\apache\Apache24 bin\apache >nul 2>&1^
		&& echo SUCCESS
	) || (
		echo FAILED & goto quit
	)
	set MSVC_RUNTIME_REQUIRED=1
)

if not exist bin\mysql\bin\mysql.exe (
	if exist bin\mysql rd /q /s bin\mysql >nul 2>&1
	(
		echo. | set /p v="Installing MySQL 8.0.30..."^
		&& powershell -Command "$progressPreference = 'silentlyContinue'; Invoke-WebRequest -Method Get -Uri 'https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.30-winx64.zip' -OutFile '%CD%\temp\mysql.zip';" >nul 2>&1^
		&& powershell -Command "$progressPreference = 'silentlyContinue'; Expand-Archive -Path '%CD%\temp\mysql.zip' -DestinationPath '%CD%\temp\mysql' -Force;" >nul 2>&1^
		&& move temp\mysql\mysql-8.0.30-winx64 bin\mysql >nul 2>&1^
		&& echo SUCCESS
	) || (
		echo FAILED & goto quit
	)
	set MSVC_RUNTIME_REQUIRED=1
)

if not exist bin\php\php.exe (
	if exist bin\php rd /q /s bin\php >nul 2>&1
	(
		echo. | set /p v="Installing PHP 7.4.30..."^
		&& powershell -Command "$progressPreference = 'silentlyContinue'; Invoke-WebRequest -Method Get -Uri 'https://windows.php.net/downloads/releases/php-7.4.30-Win32-vc15-x64.zip' -OutFile '%CD%\temp\php.zip';" >nul 2>&1^
		&& powershell -Command "$progressPreference = 'silentlyContinue'; Expand-Archive -Path '%CD%\temp\php.zip' -DestinationPath '%CD%\temp\php' -Force;" >nul 2>&1^
		&& move temp\php bin\php >nul 2>&1^
		&& echo SUCCESS
	) || (
		echo FAILED & goto quit
	)
	set MSVC_RUNTIME_REQUIRED=1
)

if not exist bin\apache\bin\libssh2.dll (
	copy bin\php\libssh2.dll bin\apache\bin\libssh2.dll >nul 2>&1
)

if not exist bin\composer\composer.phar (
	if not exist bin\composer md bin\composer >nul 2>&1
	(
		echo. | set /p v="Installing Composer 2.3.10..."^
		&& powershell -Command "$progressPreference = 'silentlyContinue'; Invoke-WebRequest -Method Get -Uri 'https://getcomposer.org/download/2.3.10/composer.phar' -OutFile '%CD%\bin\composer\composer.phar';" >nul 2>&1^
		&& echo SUCCESS
	) || (
		echo FAILED & goto quit
	)
)

if not exist bin\composer\composer.bat (
	echo ^@"%CD%\bin\php\php.exe" "%CD%\bin\composer\composer.phar" %%* > bin\composer\composer.bat
)

if not exist bin\node\node.exe (
	if exist bin\node rd /q /s bin\node >nul 2>&1
	(
		echo. | set /p v="Installing Node.js 16.16.0..."^
		&& powershell -Command "$progressPreference = 'silentlyContinue'; Invoke-WebRequest -Method Get -Uri 'https://nodejs.org/dist/v16.16.0/node-v16.16.0-win-x64.zip' -OutFile '%CD%\temp\node.zip';" >nul 2>&1^
		&& powershell -Command "$progressPreference = 'silentlyContinue'; Expand-Archive -Path '%CD%\temp\node.zip' -DestinationPath '%CD%\temp\node' -Force;" >nul 2>&1^
		&& move temp\node\node-v16.16.0-win-x64 bin\node >nul 2>&1^
		&& echo SUCCESS
	) || (
		echo FAILED & goto quit
	)
	set MSVC_RUNTIME_REQUIRED=1
)

if not exist pma/index.php (
	if exist pma rd /q /s pma >nul 2>&1
	(
		echo. | set /p v="Installing phpMyAdmin 5.2.0..."^
		&& powershell -Command "$progressPreference = 'silentlyContinue'; Invoke-WebRequest -Method Get -Uri 'https://files.phpmyadmin.net/phpMyAdmin/5.2.0/phpMyAdmin-5.2.0-all-languages.zip' -OutFile '%CD%\temp\pma.zip';" >nul 2>&1^
		&& powershell -Command "$progressPreference = 'silentlyContinue'; Expand-Archive -Path '%CD%\temp\pma.zip' -DestinationPath '%CD%\temp\pma' -Force;" >nul 2>&1^
		&& move temp\pma\phpMyAdmin-5.2.0-all-languages pma >nul 2>&1^
		&& echo SUCCESS
	) || (
		echo FAILED & goto quit
	)
)

if not exist conf\php\ssl\cacert.pem (
	if not exist conf\php\ssl md conf\php\ssl >nul 2>&1
	(
		echo. | set /p v="Installing OpenSSL CA certificate..."^
		&& powershell -Command "$progressPreference = 'silentlyContinue'; Invoke-WebRequest -Method Get -Uri 'https://curl.se/ca/cacert.pem' -OutFile '%CD%\conf\php\ssl\cacert.pem';" >nul 2>&1^
		&& echo SUCCESS
	) || (
		echo FAILED & goto quit
	)
)

if defined MSVC_RUNTIME_REQUIRED (
	(
		echo. | set /p v="Installing MSVC runtime (x64)..."^
		&& powershell -Command "$progressPreference = 'silentlyContinue'; Invoke-WebRequest -Method Get -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile '%CD%\temp\vc_redist.x64.exe';" >nul 2>&1^
		&& temp\vc_redist.x64.exe /install /quiet /norestart >nul 2>&1^
		&& echo SUCCESS
	) || (
		echo FAILED & goto quit
	)
)

if defined MSVC_RUNTIME_REQUIRED (
	(
		echo. | set /p v="Installing MSVC runtime (x86)..."^
		&& powershell -Command "$progressPreference = 'silentlyContinue'; Invoke-WebRequest -Method Get -Uri 'https://aka.ms/vs/17/release/vc_redist.x86.exe' -OutFile '%CD%\temp\vc_redist.x86.exe';" >nul 2>&1^
		&& temp\vc_redist.x86.exe /install /quiet /norestart >nul 2>&1^
		&& echo SUCCESS
	) || (
		echo FAILED & goto quit
	)
)

if not exist pma\config.inc.php (
	(
		echo ^<?php
		echo.
		echo $i = 1;
		echo.
		echo $cfg['Servers'][$i]['host'] = '127.0.0.1';
		echo.
		echo $cfg['Servers'][$i]['auth_type'] = 'config';
		echo.
		echo $cfg['Servers'][$i]['user'] = 'root';
		echo $cfg['Servers'][$i]['password'] = 'root';
		echo.
		echo $cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';
		echo.
		echo $cfg['Servers'][$i]['bookmarktable']  = 'pma__bookmark';
		echo $cfg['Servers'][$i]['central_columns']  = 'pma__central_columns';
		echo $cfg['Servers'][$i]['column_info']  = 'pma__column_info';
		echo $cfg['Servers'][$i]['designer_settings']  = 'pma__designer_settings';
		echo $cfg['Servers'][$i]['export_templates']  = 'pma__export_templates';
		echo $cfg['Servers'][$i]['favorite']  = 'pma__favorite';
		echo $cfg['Servers'][$i]['history']  = 'pma__history';
		echo $cfg['Servers'][$i]['navigationhiding']  = 'pma__navigationhiding';
		echo $cfg['Servers'][$i]['pdf_pages']  = 'pma__pdf_pages';
		echo $cfg['Servers'][$i]['recent']  = 'pma__recent';
		echo $cfg['Servers'][$i]['relation']  = 'pma__relation';
		echo $cfg['Servers'][$i]['savedsearches']  = 'pma__savedsearches';
		echo $cfg['Servers'][$i]['table_coords']  = 'pma__table_coords';
		echo $cfg['Servers'][$i]['table_info']  = 'pma__table_info';
		echo $cfg['Servers'][$i]['table_uiprefs']  = 'pma__table_uiprefs';
		echo $cfg['Servers'][$i]['tracking']  = 'pma__tracking';
		echo $cfg['Servers'][$i]['userconfig']  = 'pma__userconfig';
		echo $cfg['Servers'][$i]['usergroups']  = 'pma__usergroups';
		echo $cfg['Servers'][$i]['users']  = 'pma__users';
		echo.
		echo $cfg['Servers'][$i]['SessionTimeZone'] = '+00:00';
		echo.
		echo $cfg['DefaultConnectionCollation'] = 'utf8mb4_0900_ai_ci';
		echo.
		echo $cfg['ExecTimeLimit'] = 300;
		echo.
		echo $cfg['Lang'] = 'en';
		echo.
		echo $cfg['MaxDbList'] = $cfg['MaxTableList'] = $cfg['MaxNavigationItems'] = $cfg['FirstLevelNavigationItems'] = 250;
		echo.
		echo $cfg['NavigationTreeDisplayDbFilterMinimum'] = $cfg['MaxDbList'];
		echo.
		echo $cfg['NavigationTreeDisplayItemFilterMinimum'] = $cfg['MaxNavigationItems'];
		echo $cfg['NavigationTreeEnableGrouping'] = FALSE;
		echo.
		echo $cfg['NumRecentTables'] = $cfg['NumFavoriteTables'] = 0;
		echo.
		echo $cfg['ShowPhpInfo'] = TRUE;
		echo.
		echo $cfg['ThemeManager'] = FALSE;
		echo.
		echo $cfg['VersionCheck'] = FALSE;
	) > pma\config.inc.php
)

if not exist conf\apache\httpd.conf (
	if not exist conf\apache md conf\apache >nul 2>&1
	(
		echo DocumentRoot "%CD:\=/%/root"
		echo.
		echo ErrorLog "%CD:\=/%/logs/httpd.log"
		echo.
		echo HostnameLookups Off
		echo.
		echo KeepAlive On
		echo KeepAliveTimeout 5
		echo.
		echo Listen 127.0.0.1:80
		echo.
		echo LoadModule alias_module modules/mod_alias.so
		echo LoadModule authz_core_module modules/mod_authz_core.so
		echo LoadModule authz_host_module modules/mod_authz_host.so
		echo LoadModule dir_module modules/mod_dir.so
		echo LoadModule mime_module modules/mod_mime.so
		echo LoadModule php7_module "%CD:\=/%/bin/php/php7apache2_4.dll"
		echo LoadModule rewrite_module modules/mod_rewrite.so
		echo.
		echo LogLevel warn
		echo.
		echo PidFile "%CD:\=/%/pids/httpd.pid"
		echo.
		echo ServerAdmin admin@localhost
		echo.
		echo ServerName localhost:80
		echo.
		echo ServerRoot "%CD:\=/%/bin/apache"
		echo.
		echo ServerSignature Off
		echo.
		echo ServerTokens Prod
		echo.
		echo ^<Directory /^>
		echo     AllowOverride none
		echo     Require all denied
		echo ^</Directory^>
		echo.
		echo ^<Directory "%CD:\=/%/root"^>
		echo     Options Indexes FollowSymLinks
		echo     AllowOverride All
		echo     Require all granted
		echo ^</Directory^>
		echo.
		echo ^<Files ".ht*"^>
		echo     Require all denied
		echo ^</Files^>
		echo.
		echo ^<IfModule dir_module^>
		echo     DirectoryIndex index.html
		echo     ^<IfModule php7_module^>
		echo         DirectoryIndex index.php index.html
		echo     ^</IfModule^>
		echo ^</IfModule^>
		echo.
		echo ^<IfModule mime_module^>
		echo     TypesConfig conf/mime.types
		echo     ^<IfModule php7_module^>
		echo         AddType application/x-httpd-php .php
		echo     ^</IfModule^>
		echo ^</IfModule^>
		echo.
		echo ^<IfModule mpm_winnt_module^>
		echo     ThreadsPerChild 150
		echo     MaxConnectionsPerChild 0
		echo ^</IfModule^>
		echo.
		echo ^<IfModule php7_module^>
		echo     PHPIniDir "%CD:\=/%/conf/php/php.ini"
		echo     ^<IfModule alias_module^>
		echo         Alias /phpmyadmin "%CD:\=/%/pma"
		echo         ^<Directory "%CD:\=/%/pma"^>
		echo             AllowOverride None
		echo             Options None
		echo             Require all granted
		echo         ^</Directory^>
		echo     ^</IfModule^>
		echo ^</IfModule^>
	) > conf\apache\httpd.conf
)

if not exist conf\mysql\my.cnf (
	if not exist conf\mysql md conf\mysql >nul 2>&1
	(
		echo [mysql]
		echo.
		echo default-character-set = utf8mb4
		echo.
		echo [mysqld]
		echo.
		echo basedir = %CD:\=/%/bin/mysql
		echo.
		echo bind-address = 127.0.0.1,::1
		echo.
		echo character-set-server = utf8mb4
		echo collation-server = utf8mb4_0900_ai_ci
		echo.
		echo datadir = %CD:\=/%/data/mysql
		echo.
		echo default-authentication-plugin = mysql_native_password
		echo.
		echo default-password-lifetime = 0
		echo.
		echo default-storage-engine = InnoDB
		echo.
		echo default-time-zone = "+00:00"
		echo.
		echo default-tmp-storage-engine = InnoDB
		echo.
		echo general-log = 0
		echo.
		echo init-connect = "SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci"
		echo.
		echo innodb_buffer_pool_size = 1G
		echo innodb_log_file_size = 512M
		echo innodb_log_files_in_group = 2
		echo.
		echo log-error = %CD:\=/%/logs/mysql.log
		echo log-error-verbosity = 1
		echo.
		echo log-timestamps = SYSTEM
		echo.
		echo pid-file = %CD:\=/%/pids/mysql.pid
		echo.
		echo secure_file_priv = ""
		echo.
		echo slow-query-log = 0
	) > conf\mysql\my.cnf
)

if not exist conf\php\php.ini (
	if not exist conf\php md conf\php >nul 2>&1
	(
		type bin\php\php.ini-production
		echo [WAMP]
		echo curl.cainfo = %CD:\=/%/conf/php/ssl/cacert.pem
		echo date.timezone = UTC
		echo error_log = %CD:\=/%/logs/php.log
		echo extension=curl
		echo extension=gd2
		echo extension=mbstring
		echo extension=mysqli
		echo extension=openssl
		echo extension_dir = %CD:\=/%/bin/php/ext
		echo memory_limit = 128M
		echo opcache.enable = 1
		echo opcache.interned_strings_buffer = 8
		echo opcache.max_accelerated_files = 10000
		echo opcache.memory_consumption = 128
		echo opcache.use_cwd = 1
		echo openssl.cafile= %CD:\=/%/conf/php/ssl/cacert.pem
		echo post_max_size = 64M
		echo session.save_path = %CD:\=/%/temp
		echo session.use_strict_mode = 1
		echo sys_temp_dir = %CD:\=/%/temp
		echo upload_max_filesize = 64M
		echo zend_extension = opcache
	) > conf\php\php.ini
)

:quit

for /d %%d in (temp\*) do (
	rd /q /s %%d >nul 2>&1
)

for %%f in (temp\*.*) do (
	del /f %%f >nul 2>&1
)

popd

echo %CMDCMDLINE% | find "%~nx0" >nul 2>&1 && pause
