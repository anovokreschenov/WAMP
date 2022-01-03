@echo off

set PATH=%~dp0bin\php;%~dp0bin\composer;%~dp0bin\node;%~dp0data\npm;%PATH%

set PHPRC=%~dp0conf\php

set COMPOSER_HTACCESS_PROTECT=0
set COMPOSER_HOME=%~dp0data\composer
set COMPOSER_CACHE_DIR=%~dp0data\composer\cache

if not exist %COMPOSER_HOME% (
	md %COMPOSER_HOME% >nul 2>&1
)

if not exist %COMPOSER_CACHE_DIR% (
	md %COMPOSER_CACHE_DIR% >nul 2>&1
)

set npm_config_prefix=%~dp0data\npm
set npm_config_cache=%~dp0data\npm\cache

if not exist %npm_config_prefix% (
	md %npm_config_prefix% >nul 2>&1
)

if not exist %npm_config_cache% (
	md %npm_config_cache% >nul 2>&1
)

cd %~dp0root

echo %CMDCMDLINE% | find "%~nx0" >nul 2>&1 && start "WAMP" cmd.exe /k "cls"
