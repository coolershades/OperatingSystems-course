@echo off
SetLocal EnableExtensions EnableDelayedExpansion

set input=%*
:: см. кол-во аргументов, обрабатывать отдельно
set input=%input:"=%
if "%input%"=="" goto help
if "%input%"=="/?" goto help

set location_status=not found
set has_help=no
set found_in_path=no

set path=%path:;;=;%
set pathext=.com;.exe;.bat;.cmd;.vbs;.vbe;.js;.jse;.wsf;.wsh;.msc;.txt

for %%N in ("%input%") do (
    if exist %%~N (
        :: если кинули из текущей директории
        if exist %cd%\%%~N (
            echo %cd%\%%~N
            set location_status=external
        ) 

        set g=%%~N
        set g=!g:\=!
        if not !g!==%%~N (
            :: если кинули _текущую директорию_
            if C:%%~pN==%cd%\ (
                echo %%~N
                set location_status=external
            )
            
            :: смотрим в path'e
            for %%r in (%%~nN%%~xN) do if exist %%~$path:r (
                echo %%~$path:r
                set location_status=external
            )
        )
    )

    :: подставлям расширения
    for %%e in (%pathext%) do for %%F in ("%%~N%%e") do if exist %%~F (
        :: если есть в текущей директории
        if exist %cd%\%%~F (
            echo %cd%\%%~F
            set location_status=external
        ) 

        set g=%%~F
        set g=!g:\=!
        if not !g!==%%~F (
            :: если кинули _теущую директорию_
            if C:%%~pF==%cd%\ (
                echo %%~F
                set location_status=external
            )

            :: смотрим в path'e
            for %%r in (%%~nF%%~xF) do if exist %%~$path:r (
                echo %%~$path:r
                set location_status=external
            )
        )
    )

    set input=%%~N

    call :path_rec "%path%"
    goto :eof
)

:path_rec
for %%N in ("%input%") do for /f "tokens=1* delims=;" %%A in (%1) do (
    set g=%%A\
    if !g:~-2!==\\ set g=!g:~0,-1!
    if not ""=="%%B" (
        if exist !g!%%~N (
            echo !g!%%~nN%%~xN
            set location_status=external
            set found_in_path=yes
        )

        for %%e in (%pathext%) do if exist !g!%%~N%%e (
            echo !g!%%~N%%e
            set location_status=external
            set found_in_path=yes
        )

        call :path_rec "%%B"
        goto :eof
    ) else (
        goto cont
    )
)

:cont
for %%N in ("%input%") do (
    :: проверка в help'e
    for /F %%i in ('%SYSTEMROOT%\System32\help.exe ^| findstr /ib "\<%%~nN\>"') do (
        set location_status=internal
        set has_help=yes
        for %%j in (%pathext%) do if exist %SYSTEMROOT%\System32\%%~N%%j (
            if not %found_in_path%==yes echo %SYSTEMROOT%\System32\%%~nN%%j
            set location_status=external
        )

        if exist %SYSTEMROOT%\System32\%%~N (
            if not %found_in_path%==yes echo %SYSTEMROOT%\System32\%%~N
            set location_status=external
        )
    )
)

echo Given file is %location_status%.

if %has_help%==yes if %location_status%==internal (
    for %%N in (%input%) do if "%%~xN"=="" (
        set /p ans="Would you like to get help for this command? [y/n] "
        if !ans!==y help %%~nN
    )
)

goto :eof

:help 
echo Copyright (C) Pakhtusova Ekaterina CS-101, 2020.
echo.
echo Locates the given file in PATH/current directories and tells 
echo whether the given program is external or internal.
echo.
echo LOCATOR [path]filename[.ext]
echo.
echo [.ext] - file extension from PATHEXT
echo.
goto :eof