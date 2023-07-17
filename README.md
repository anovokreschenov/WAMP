# WAMP

**WAMP / Composer / Node.js**

**OS:** Windows 10 (x64)

| Application | Version | Source |
| ----------- | ------- | ------ |
| Apache      | 2.4.54  | https://home.apache.org/~steffenal/VC15/binaries/httpd-2.4.54-win64-VC15.zip |
| MySQL       | 8.0.33  | https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.33-winx64.zip |
| PHP         | 7.4.33  | https://windows.php.net/downloads/releases/php-7.4.33-Win32-vc15-x64.zip |
| Composer    | 2.5.8   | https://getcomposer.org/download/2.5.8/composer.phar |
| Node.js     | 18.16.0 | https://nodejs.org/dist/v18.16.0/node-v18.16.0-win-x64.zip |
| phpMyAdmin  | 5.2.1   | https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip |

### Installation

1. Clone this repository `git clone https://github.com/anovokreschenov/WAMP.git`
2. Launch the `install.cmd`

### Usage

- Use `start.cmd` and `stop.cmd` scripts to start and stop the Apache and MySQL services
- Use `shell.cmd` script to prepare the environment for executing the `php`, `composer`, `node` and `npm` commands

### Directories

| Name | Description |
| ---- | ----------- |
| bin  | Apache, MySQL, PHP, Composer and Node.js executable files and libraries |
| conf | Apache, MySQL and PHP configuration files |
| data | MySQL data storage, Composer and Node.js cache directories |
| logs | Apache, MySQL and PHP log files |
| pids | Apache and MySQL pid files |
| pma  | phpMyAdmin - http://localhost/phpmyadmin |
| root | Apache web root - http://localhost |
| temp | PHP temporary files |
