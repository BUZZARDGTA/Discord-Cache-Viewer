::------------------------------------------------------------------------------
:: NAME
::     Discord_Cache_Viewer.bat - Discord Cache Viewer
::
:: DESCRIPTION
::     Lookup your Discord "Cache" folder and for each cached files
::     create a copy trying to assign it's correct file extension.
::
:: AUTHOR
::     IB_U_Z_Z_A_R_Dl
::     Grub4K
::
:: CREDITS
::     @sintrode - General help.
::     @JCMS - Original project idea.
::     File signatures list:
::     https://en.wikipedia.org/wiki/List_of_file_signatures
::     https://www.garykessler.net/library/file_sigs.html
::     https://www.filesignatures.net/index.php?page=all
::     https://asecuritysite.com/forensics/magic
::
::     A project created in the "server.bat" Discord: https://discord.gg/GSVrHag
::------------------------------------------------------------------------------
@echo off
cls
>nul chcp 65001
setlocal DisableDelayedExpansion
cd /d "%~dp0"
set "SCRIPT_LOCATION=%~dp0"
for /f %%A in ('copy /z "%~f0" nul') do set "\r=%%A"
set "@TITLE=title Progress: [!Percentage!/100%%] - [!Counter!/!Index!]  ^|  Results: [!Results_Valid!/!Index!] - !TITLE!"
set "@SET_S=if !?! gtr 1 (set s_?=s) else (set s_?=)"
set "@CREATE_DIR=if not exist "Results\!DATETIME!\?\" md "Results\!DATETIME!\?""
setlocal EnableDelayedExpansion
set TITLE=Discord Cache Viewer
title !TITLE!
set "HIDECURSOR=<nul set /p=[?25l"
%HIDECURSOR%
if defined TEMP (set "TMPF=!TEMP!") else if defined TMP (set "TMPF=!TMP!") else (
    call :MSGBOX 2 "Your 'TEMP' and 'TMP' environment variables do not exist." "Please fix one of them and try again." 69648 "!TITLE!"
    exit
)
if not exist binread.exe (
    call :MSGBOX 2 "ERROR: '%~dp0binread.exe' not found." "Exiting !TITLE!..." 69648 "!TITLE!"
    exit
)
for /f "tokens=2delims==." %%A in ('wmic os get LocalDateTime /value') do (
    set "DATETIME=%%A"
    set "DATETIME=!DATETIME:~0,-10!-!DATETIME:~-10,2!-!DATETIME:~-8,2!_!DATETIME:~-6,2!-!DATETIME:~-4,2!-!DATETIME:~-2!"
)
set /a Percentage=0, Counter=0, Index=0, Results_Valid=0, Processed=0
set Splitted_Files=
set x=
echo.
for %%A in (discord discordptb discordcanary) do (
    if not defined x (
        for /f "skip=1tokens=1delims=," %%B in ('tasklist /fo csv /fi "imagename eq %%A.exe"') do (
            if not defined x (
                if /i "%%~B"=="%%A.exe" (
                    set x=1
                    echo  ■ [WARNING] Discord client running. Minor errors might occur.
                    echo.
                )
            )
        )
    )
)
for /f "tokens=1-4delims=:.," %%A in ("!time: =0!") do set /a "t1=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100"
for %%A in (discord discordptb discordcanary) do (
    for /f %%B in ('2^>nul dir "%AppData%\%%A\Cache\f_*." /a:-d /b') do (
        set /a Index+=1
        %@TITLE%
    )
)
for %%A in (discord discordptb discordcanary) do (
    for /f %%B in ('2^>nul dir "%AppData%\%%A\Cache\f_*." /a:-d /b /o:d') do (
        set /a Counter+=1, Percentage=Counter*100/Index, PB_Progress=Percentage/4, Results_Valid+=Processed, Processed=0
        set Progress_Bar=
        set ext=
        set x=
        %@TITLE%
        for /l %%. in (1,1,!PB_Progress!) do (
            set Progress_Bar=!Progress_Bar!█
        )
        set "Progress_Bar=!Progress_Bar!░░░░░░░░░░░░░░░░░░░░░░░░░"
        <nul set /p=" ■ Processeding cached file: "%%~nB" │!Progress_Bar:~0,25!│ (!Percentage!/100%%)!\r!"
        for /f %%C in ('binread.exe "%AppData%\%%A\Cache\%%~nB" 24') do (
            set x=!x!%%C
        )
        if "!x:~0,16!"=="89504E470D0A1A0A" (
            set ext=png
        ) else if "!x:~0,24!"=="FFD8FFE000104A4649460001" (
            set ext=jpg
        ) else if "!x:~0,8!"=="FFD8FFE1" (
            if "!x:~12,12!"=="457869660000" (
                set ext=jpg
            )
        ) else if "!x:~0,8!"=="FFD8FFDB" (
            set ext=jpg
        ) else if "!x:~8,16!"=="6674797069736F6D" (
            set ext=mp4
        ) else if "!x:~0,4!"=="1F8B" (
            set ext=gz
        ) else if "!x:~0,6!"=="494433" (
            set ext=mp3
        ) else if "!x:~0,12!"=="474946383961" (
            set ext=gif
        ) else if "!x:~0,8!"=="4F676753" (
            set ext=ogg
        ) else if "!x:~0,8!"=="52494646" (
            if "!x:~16,8!"=="57454250" (
                set ext=webp
            )
            if "!x:~16,8!"=="57415645" (
                rem from unofficial source: https://www.garykessler.net/library/file_sigs.html
                set ext=wav
            )
        ) else if "!x:~0,8!"=="1A45DFA3" (
            set ext=webm
        ) else if "!x:~0,8!"=="774F4632" (
            set ext=woff2
        ) else if "!x:~8,16!"=="667479706D703432" (
            rem from unofficial source: https://www.garykessler.net/library/file_sigs.html
            set ext=m4v
        ) else if "!x:~8,16!"=="6674797071742020" (
            rem from unofficial source: https://www.garykessler.net/library/file_sigs.html
            set ext=mov
        ) else if "!x:~8,14!"=="66747970336770" (
            rem from unofficial source: https://www.garykessler.net/library/file_sigs.html
            set ext=3gp
        ) else if "!x:~8,16!"=="667479704D344120" (
            rem from unofficial source: https://www.garykessler.net/library/file_sigs.html
            set ext=m4a
        ) else if "!x:~8,16!"=="667479706D703431" (
            rem from unofficial source: https://www.garykessler.net/library/file_sigs.html
            set ext=mp4
        )
        for %%D in ("%AppData%\%%A\Cache\%%~nB") do (
            if "%%~zD"=="1048576" (
                if defined ext (
                    for %%E in (mp4 m4a m4v wav webm ogg) do (
                        if "!ext!"=="%%E" (
                            set "Splitted_Files=%%~nB"
                            set "Splitted_Files_Name=%%~nB.!ext!"
                        )
                    )
                ) else (
                    if defined Splitted_Files (
                        set "Splitted_Files=!Splitted_Files!+%%~nB"
                    )
                )
            ) else (
                if defined Splitted_Files (
                    if %%~zD lss 1048576 (
                        set "Splitted_Files=!Splitted_Files!+%%~nB"
                        %@CREATE_DIR:?=ResolvedCache%
                        pushd "%AppData%\%%A\Cache"
                        >nul copy /b !Splitted_Files! "!SCRIPT_LOCATION!Results\!DATETIME!\ResolvedCache\!Splitted_Files_Name!"
                        popd
                        %@CREATE_DIR:?=Logs%
                        >>Results\!DATETIME!\Logs\Resolved_File_Signatures.txt echo !Splitted_Files_Name!=!Splitted_Files!
                        set Splitted_Files=
                        set Splitted_Files_Name=
                        set Processed=1
                    )
                ) else (
                    if defined ext (
                        %@CREATE_DIR:?=ResolvedCache%
                        >nul copy "%AppData%\%%A\Cache\%%~nB" "Results\!DATETIME!\ResolvedCache\%%~nB.!ext!"
                        %@CREATE_DIR:?=Logs%
                        >>Results\!DATETIME!\Logs\Resolved_File_Signatures.txt echo %%~nB.!ext!=%%~nB
                        set Processed=1
                    ) else (
                        %@CREATE_DIR:?=UnresolvedCache%
                        >nul copy "%AppData%\%%A\Cache\%%~nB" "Results\!DATETIME!\UnresolvedCache\%%~nB"
                        >nul 2>&1 find "!x!" "Results\!DATETIME!\Logs\Unresolved_File_Signatures.txt" || (
                            %@CREATE_DIR:?=Logs%
                            >>Results\!DATETIME!\Logs\Unresolved_File_Signatures.txt echo %%~nB=!x!
                        )
                    )
                )
            )
        )
    )
)
for /f "tokens=1-4delims=:.," %%A in ("!time: =0!") do set /a "t2=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100, tDiff=t2-t1, tDiff+=((~(tDiff&(1<<31))>>31)+1)*8640000, Seconds=tDiff/100"
set /a Percentage=100, Results_Valid+=Processed
%@SET_S:?=Index%
%@SET_S:?=Seconds%
%@TITLE%
echo.
echo.
echo  ■ Renamed !Results_Valid!/!Index! cache file!s_Index! in !Seconds! second!s_Seconds!.
if exist "Results\!DATETIME!\ResolvedCache" start /max "" "Results\!DATETIME!\ResolvedCache"
echo.
<nul set /p= ■ Press {ANY KEY} to exit...
>nul pause
exit

:MSGBOX
if "%1"=="2" mshta vbscript:Execute("msgbox ""%~2"" & Chr(10) & Chr(10) & ""%~3"",%4,""%~5"":close")
exit /b