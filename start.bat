@echo off
setlocal enabledelayedexpansion


:: Function to get user input
:ask_mysql
set "mysql_choice="
set /p mysql_input="Do you want to start MySQL service? [Y/n] "
if /i "!mysql_input!"=="" set mysql_choice=y
if /i "!mysql_input!"=="y" set mysql_choice=y
if /i "!mysql_input!"=="n" set mysql_choice=n
if not defined mysql_choice (
    echo Invalid input. Please enter Y/y or N/n.
    goto ask_mysql
)

:ask_redis
set "redis_choice="
set /p redis_input="Do you want to start Redis service? [Y/n] "
if /i "!redis_input!"=="" set redis_choice=y
if /i "!redis_input!"=="y" set redis_choice=y
if /i "!redis_input!"=="n" set redis_choice=n
if not defined redis_choice (
    echo Invalid input. Please enter Y/y or N/n.
    goto ask_redis
)

:: initialize the passwords
set mysqlpassword=
set redispassword=

:: Get the passwords from the .env file
for /f "usebackq tokens=1,2 delims==" %%a in (`findstr /r "MYSQL_ROOT_PASSWORD REDIS_PASSWORD" docker-compose\.env`) do (
    if "%%a"=="MYSQL_ROOT_PASSWORD" (
        set mysqlpassword=%%b
    ) else if "%%a"=="REDIS_PASSWORD" (
        set redispassword=%%b
    )
)
:: set the passwords if they are not set
$env:MYSQL_ROOT_PASSWORD=!mysqlpassword!
$env:REDIS_PASSWORD=!redispassword!

:: Determine which docker-compose file to use
if "!mysql_choice!!redis_choice!"=="nn" (
    @REM echo Starting services with docker-compose.yml...
    docker-compose up -d
) else if "!mysql_choice!!redis_choice!"=="yn" (
    @REM echo Starting services with docker-compose10.yml...
    :: Display the generated password
    echo Root MySQL password: %mysqlpassword%
    docker-compose -f docker-compose/docker-compose10.yml up -d
) else if "!mysql_choice!!redis_choice!"=="ny" (
    @REM echo Starting services with docker-compose01.yml...
    :: Display the generated password
    echo Redis password: %redispassword%
    docker-compose -f docker-compose/docker-compose01.yml up -d
) else if "!mysql_choice!!redis_choice!"=="yy" (
    @REM echo Starting services with docker-compose11.yml...
    :: Display the generated password
    echo Root MySQL password: %mysqlpassword%
    echo Redis password: %redispassword%
    docker-compose -f docker-compose/docker-compose11.yml up -d
) else (
    echo Unexpected case. Please check your input.
)

:: Set the container name and bash script path
set CONTAINER_NAME=pt-php
set BASH_SCRIPT_PATH=./docker-compose/sh/timetask.sh
set CONTAINER_BASH_SCRIPT_PATH=/opt/timetask.sh

:: Copy the bash script to the container
docker cp %BASH_SCRIPT_PATH% %CONTAINER_NAME%:%CONTAINER_BASH_SCRIPT_PATH%

:: Execute the bash script in the container
docker exec -it %CONTAINER_NAME% sh -c "sh %CONTAINER_BASH_SCRIPT_PATH%"

:: Check the error level of the script execution
if %errorlevel% neq 0 (
    echo Timed task script execution failed!
    echo Please enter the container and execute related commands manually.
) else (
    echo Timed task script executed successfully!
)

endlocal