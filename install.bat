@echo off
setlocal enabledelayedexpansion

set "CodePath=./NexusPHP"
:: Remove the code directory if it exists
if exist "%CodePath%" (
    rmdir /s /q "%CodePath%"
)
set "DataPath=./data"
:: Remove the data directory if it exists
if exist "%DataPath%" (
    rmdir /s /q "%DataPath%"
)
set "LogPath=./log"
:: Remove the data directory if it exists
if exist "%LogPath%" (
    rmdir /s /q "%LogPath%"
)
:: Clone the repository
git submodule update
:: Wait for 5 seconds to finshed cloning
timeout /t 5 /nobreak > nul
:: Copy the install files to the public directory
set "sourceDir=./NexusPHP/nexus/Install/install"
set "targetDir=./NexusPHP/public/install"
:CopyFiles
if exist "%sourceDir%" (
    xcopy "%sourceDir%" "%targetDir%" /s /e /i /y /q
) else (
    timeout /t 5 /nobreak > nul
    goto CopyFiles
)

:: Function to generate a random password
set "charset=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
set "mysqlpassword="
set "redispassword="
set "password_length=16"

:: Generate MySQL password
for /L %%i in (1,1,%password_length%) do (
    set /A "index=!random! %% 62"
    for %%j in (!index!) do (
        set "mysqlpassword=!mysqlpassword!!charset:~%%j,1!"
    )
)

:: Generate Redis password
for /L %%i in (1,1,%password_length%) do (
    set /A "index=!random! %% 62"
    for %%j in (!index!) do (
        set "redispassword=!redispassword!!charset:~%%j,1!"
    )
)

:: Save passwords to a .env file for Docker Compose
(
    echo MYSQL_ROOT_PASSWORD=!mysqlpassword!
    echo REDIS_PASSWORD=!redispassword!
) > docker-compose/.env

call ./start.bat

:: Set the sql script path
@REM set CONTAINER_NAME=pt-mysql
@REM set SQL_SCRIPT_PATH=./docker-compose/sql/install.sql
@REM set CONTAINER_SQL_SCRIPT_PATH=/opt/install.sql

:: Copy the SQL script to the container
@REM docker cp %SQL_SCRIPT_PATH% %CONTAINER_NAME%:%CONTAINER_SQL_SCRIPT_PATH%

:: Execute the SQL script
@REM docker exec -i %CONTAINER_NAME% mysql -u root -p!MYSQL_ROOT_PASSWORD! < %CONTAINER_SQL_SCRIPT_PATH%

:: Check the result of the SQL script execution
@REM if %errorlevel% neq 0 (
@REM     echo SQL script execution failed!
@REM     echo Please create the database "nexusphp" by use the following command:
@REM     echo create database `nexusphp` default charset=utf8mb4 collate utf8mb4_general_ci;
@REM ) else (
@REM     echo SQL script executed successfully!
@REM )

echo installation completed