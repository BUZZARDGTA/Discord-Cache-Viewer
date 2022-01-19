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
pushd "%~dp0"
for /f %%A in ('copy /z "%~nx0" nul') do (
    set "\R=%%A"
)
for /f "tokens=1,2delims=`" %%A in ('forfiles /m "%~nx0" /c "cmd /c echo 0x1B`0x08"') do (
    set "\E=%%A"
    set "\B=%%B"
)
set "@SHOWCURSOR=<nul set /p=!\E![?25h"
set "@HIDECURSOR=<nul set /p=!\E![?25l"
set "@TITLE=title Progress: [!Percentage!%%] - [!Counter!/!Index!]  ^|  Results: [!Results_Valid!/!Index!] - !TITLE!"
set "@CREATE_DIR=if not exist "Results\!DATETIME!\?\" md "Results\!DATETIME!\?""
set "@SET_S=if !?! gtr 1 (set s_?=s) else (set s_?=)"
set "REGEX_ATTACHMENTS=cdn\.discordapp\.com\/avatars\/[0-9]{18}\/(a_)?[a-z0-9]{32}\.(webp|png|gif)(\?(format=(webp|png|gif))?&?((size=[0-9]{1,4})|(width=[0-9]+&height=[0-9]+)))?"
set "REGEX_AVATARS=(cdn\.discordapp\.com|media\.discordapp\.net)\/attachments\/[0-9]{18}\/[0-9]{18}\/(\w|-|\.)+(\?((size=[0-9]{1,4})|(width=[0-9]+&height=[0-9]+)|(format=(jpeg|png)(&width=[0-9]+&height=[0-9]+)?)))?"
set "REGEX_ASSETS=discord\.com\/assets\/(((([0-9a-z]{20}|[0-9a-z]{32})(\.worker)?(\.(js|json|css|woff|mp3|svg|png|mp4|webm)))|(version\.stable\.json\?_=[0-9]{7}))|([0-9]{3}\.[0-9a-z]{20}\.css))"
set "REGEX_EMOJIS=cdn\.discordapp\.com\/emojis\/[a-z0-9]{18}\.(webp|gif|png)(\?size=[0-9]{2}&quality=lossless)?"
set "REGEX_URLS=(%REGEX_ATTACHMENTS%)|(%REGEX_AVATARS%)|(%REGEX_ASSETS%)|(%REGEX_EMOJIS%)"
setlocal EnableDelayedExpansion
set TITLE=Discord Cache Viewer
title !TITLE!
%@HIDECURSOR%
echo:
echo  ■ [INFORMATION] Searching the dependencies presence ...
set lookup_exit_error=
if defined ProgramFiles(x86) (
    set ARCH=64
) else (
    set ARCH=86
)
for %%A in (curl grep) do (
    for %%B in ("lib\%%A\x!ARCH!\%%A.exe") do (
        if exist "%%~B" (
            if %%A==grep (
                set "GREP_PATH=%%~B"
            )
            echo  ├ [INFORMATION] "%%~B" found.
            set "PATH=lib\%%A\x!ARCH!;!PATH!lib\%%A\x!ARCH!;"
        ) else (
            set lookup_exit_error=!lookup_exit_error!`%%A`
            echo  └├ [WARNING    ] "%%~B" not found.
        )
    )
)
for %%A in ("lib\binread.exe") do (
    if exist "%%~A" (
        set "BINREAD_PATH=%%~A"
        echo  ├ [INFORMATION] "%%~A" found.
    ) else (
        set lookup_exit_error=!lookup_exit_error!`%%A`
        echo  ├ [WARNING    ] "%%~A" not found.
    )
)
if defined lookup_exit_error (
    if not "!lookup_exit_error:`curl`=!"=="!lookup_exit_error!" (
        >nul 2>&1 where curl.exe && (
            set lookup_exit_error=!lookup_exit_error:`curl`=!
            echo  ├ [INFORMATION] "curl.exe" found in your system PATH.
        )
    )
)
if defined lookup_exit_error (
    echo  └ [ERROR      ] One or more required dependencies are missing from source folder.
    goto :FINISHED
)
echo  └ [INFORMATION] Finished searching all required dependencies.
for /f "tokens=2delims==." %%A in ('wmic os get LocalDateTime /value') do (
    set "DATETIME=%%A"
    set "DATETIME=!DATETIME:~0,-10!-!DATETIME:~-10,2!-!DATETIME:~-8,2!_!DATETIME:~-6,2!-!DATETIME:~-4,2!-!DATETIME:~-2!"
)
set Discord_Running=
echo:
:JUMP_1
for %%A in (Discord.exe DiscordCanary.exe DiscordPTB.exe) do (
    for /f "skip=1delims=," %%B in ('tasklist /fo csv /fi "imagename eq %%A"') do (
        if /i "%%~B"=="%%A" (
            set Discord_Running=1
            cls
            echo:
            echo  ■ [WARNING    ] Discord client running. Minor errors might occur.
            <nul set /p=".!\B! ├ [QUESTION   ] Do you want to close Discord and try again? [Y,N]: "
            %@SHOWCURSOR%
            >nul choice /c YN
            set el=!errorlevel!
            %@HIDECURSOR%
            if !el!==1 (
                echo Y
                echo  ├ [INFORMATION] Now trying closing "%%A" ...
                >nul 2>&1 taskkill /im "%%A" /f || (
                    goto :JUMP_1
                )
                set Discord_Running=0
                >nul timeout /t 1 /nobreak
                goto :JUMP_1
            )
            echo N
            goto :JUMP_2
        )
    )
)
:JUMP_2
if defined Discord_Running (
    if !Discord_Running!==0 (
        echo  └ [INFORMATION] Finished closing your Discord client.
        set Discord_Running=
    ) else (
        echo  └ [INFORMATION] Closing your Discord client aborted.
    )
    echo:
)
set x=0
for %%A in (discord discordcanary discordptb) do (
    if exist "%AppData%\%%A\Cache\" (
        set /a x+=1
    )
)
if defined x (
    if !x! gtr 1 (
        set s_Folders=s
    )
    set x=
)
set x=1
echo  ■ [INFORMATION] Backing up your Discord "cache" folder!s_Folders! in "Results\!DATETIME!\Backup\" ...
for %%A in (discord discordcanary discordptb) do (
    if exist "%AppData%\%%A\Cache\" (
        if not exist "Results\!DATETIME!\Backup\%%A\Cache\" (
            md "Results\!DATETIME!\Backup\%%A\Cache"
        )
        for %%B in ("%AppData%\%%A\Cache\*") do (
            >nul 2>&1 copy /b "%%~fB" "Results\!DATETIME!\Backup\%%A\Cache\%%~nxB" || (
                echo  ├ [WARNING    ] Discord client running. Failed backing up the file "%%~nxB".
                if "%%~nxB"=="data_1" (
                    echo  ├ [WARNING    ] Discord client running. Downloading the "data_1" cached URLs disabled for this session.
                    set Discord_Running==1
                )
            )
            if defined x (
                if !errorlevel!==0 (
                    set x=
                )
            )
        )
    )
)
if defined x (
    set x=
    echo  └ [WARNING    ] No Discord cached files detected. Program aborted.
    goto :FINISHED
)
echo  ├ [INFORMATION] If you wish, you can now open your Discord client.
echo  └ [INFORMATION] Finished backing up your your Discord "cache" folder!s_Folders!.
echo:
<nul set /p=".!\B! ■ [INFORMATION] Processing your Discord cache folder!s_Folders! ..."
echo:
set /a Percentage=0, Counter=0, Index=0, Results_Valid=0, Processed=0
set Progress_Bar=
set Splitted_Files=
for /f "tokens=1-4delims=:.," %%A in ("!time: =0!") do set /a "t1=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100"
for %%A in (discord discordcanary discordptb) do (
    for /f %%B in ('2^>nul dir "Results\!DATETIME!\Backup\%%A\Cache\f_*." /a:-d /b') do (
        set /a Index+=1
        %@TITLE%
    )
)
for %%A in (discord discordcanary discordptb) do (
    for /f %%B in ('2^>nul dir "Results\!DATETIME!\Backup\%%A\Cache\f_*." /a:-d /b /o:d') do (
        set /a Counter+=1, Percentage=Counter*100/Index, PB_Progress=Percentage/4, Results_Valid+=Processed, Processed=0
        set Progress_Bar=
        set ext=
        set x=
        %@TITLE%
        for /l %%. in (1,1,!PB_Progress!) do (
            set Progress_Bar=!Progress_Bar!█
        )
        set "Progress_Bar=!Progress_Bar!░░░░░░░░░░░░░░░░░░░░░░░░░"
        set "pad=%%~nB........"
        <nul set /p=".!\B! ├ [INFORMATION] Renaming the cached file: "!pad:~0,8!..." │!Progress_Bar:~0,25!│ (!Percentage!%%)!\R!"
        for /f %%C in ('%BINREAD_PATH% "Results\!DATETIME!\Backup\%%A\Cache\%%~nB" 24') do (
            set "x=!x!%%C"
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
        for %%D in ("Results\!DATETIME!\Backup\%%A\Cache\%%~nB") do (
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
                %@CREATE_DIR:?=Logs%
                if defined Splitted_Files (
                    if %%~zD lss 1048576 (
                        set "Splitted_Files=!Splitted_Files!+%%~nB"
                        %@CREATE_DIR:?=Cache%
                        pushd "Results\!DATETIME!\Backup\%%A\Cache"
                        >nul copy /b !Splitted_Files! "..\..\..\Cache\!Splitted_Files_Name!"
                        popd
                        >>"Results\!DATETIME!\Logs\Resolved_File_Signatures.txt" (
                            echo !Splitted_Files_Name!=!Splitted_Files!
                        )
                        set Splitted_Files=
                        set Splitted_Files_Name=
                        set Processed=1
                    )
                ) else (
                    if defined ext (
                        %@CREATE_DIR:?=Cache%
                        >nul copy "Results\!DATETIME!\Backup\%%A\Cache\%%~nB" "Results\!DATETIME!\Cache\%%~nB.!ext!"
                        >>"Results\!DATETIME!\Logs\Resolved_File_Signatures.txt" (
                            echo %%~nB.!ext!=%%~nB
                        )
                        set Processed=1
                    ) else (
                        >nul 2>&1 find "!x!" "Results\!DATETIME!\Logs\Unresolved_File_Signatures.txt" || (
                            >>"Results\!DATETIME!\Logs\Unresolved_File_Signatures.txt" (
                                echo %%~nB=!x!
                            )
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
if defined Progress_Bar (
    echo:
)
echo  └ [INFORMATION] Finished renaming the !Results_Valid!/!Index! cached file!s_Index! in !Seconds! second!s_Seconds!.
if exist "Results\!DATETIME!\Cache\" (
    start /max "" "Results\!DATETIME!\Cache"
)
if defined Discord_Running (
    goto :FINISHED
)
echo:
echo  ■ [INFORMATION] Processing the 'data_1' cached URLs ...
echo  ├ [INFORMATION] Checking your internet connection ...
>nul curl -fkLs https://1.1.1.1/ || (
    >nul curl -fkLs https://8.8.8.8/ || (
        echo  └ [WARNING    ] No internet connection detected. Downloading the 'data_1' cached URLs aborted.
        goto :FINISHED
    )
)
<nul set /p=".!\B! ├ [QUESTION   ] Do you want to download the 'data_1' cached URLs? [Y,N]: "
%@SHOWCURSOR%
>nul choice /c YN
set el=!errorlevel!
%@HIDECURSOR%
if !el!==2 (
    echo N
    echo  └ [INFORMATION] Downloading the 'data_1' cached URLs aborted.
    goto :FINISHED
)
echo Y
set /a Percentage=0, Counter=0, Index=0, Results_Valid=0
set Progress_Bar=
%@TITLE%
for /f "tokens=1-4delims=:.," %%A in ("!time: =0!") do set /a "t1=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100"
for %%A in (discord discordcanary discordptb) do (
    if exist "Results\!DATETIME!\Backup\%%A\Cache\data_1" (
        for /f "delims=" %%A in ('2^>nul %GREP_PATH% -EioaU "!REGEX_URLS!" "Results\!DATETIME!\Backup\%%A\Cache\data_1"') do (
            set /a Index+=1
            %@TITLE%
        )
    )
)
for %%A in (discord discordcanary discordptb) do (
    if exist "Results\!DATETIME!\Backup\%%A\Cache\data_1" (
        for /f "delims=" %%B in ('2^>nul %GREP_PATH% -EioaU "!REGEX_URLS!" "Results\!DATETIME!\Backup\%%A\Cache\data_1"') do (
            set /a Counter+=1, Percentage=Counter*100/Index, PB_Progress=Percentage/4
            set Progress_Bar=
            %@TITLE%
            for /l %%. in (1,1,!PB_Progress!) do (
                set Progress_Bar=!Progress_Bar!█
            )
            set "Progress_Bar=!Progress_Bar!░░░░░░░░░░░░░░░░░░░░░░░░░"
            set "pad=%%~nB........"
            <nul set /p=".!\B! ├ [INFORMATION] Downloading the cached URL: "!pad:~0,8!..." │!Progress_Bar:~0,25!│ (!Percentage!%%)!\R!"
            set "folder=%%B"
            for /f "delims=?" %%C in ("%%B") do (
                if not "!folder:/avatars/=!"=="!folder!" (
                    set "folder=avatars"
                ) else if not "!folder:/attachments/=!"=="!folder!" (
                    set "folder=attachments"
                ) else if not "!folder:/assets/=!"=="!folder!" (
                    set "folder=assets"
                ) else if not "!folder:/emojis/=!"=="!folder!" (
                    set "folder=emojis"
                ) else (
                    set folder=
                )
                if defined folder (
                    set "dst=%%~nxC"
                    if defined dst (
                        if exist "Results\!DATETIME!\data_1\!folder!\!dst!" (
                            call :FORM_VALID_FILE_NAME
                        )
                        %@CREATE_DIR:?=Logs%
                        curl.exe --create-dirs -fkso "Results\!DATETIME!\data_1\!folder!\!dst!" "https://%%B"
                        if !errorlevel!==0 (
                            set /a Results_Valid+=1
                            >>"Results\!DATETIME!\Logs\Resolved_Downloaded_URLs.txt" (
                                echo https://%%B
                            )
                        ) else (
                            >>"Results\!DATETIME!\Logs\Unresolved_Downloaded_URLs.txt" (
                                echo https://%%B
                            )
                        )
                    )
                )
            )
        )
    )
)
for /f "tokens=1-4delims=:.," %%A in ("!time: =0!") do set /a "t2=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100, tDiff=t2-t1, tDiff+=((~(tDiff&(1<<31))>>31)+1)*8640000, Seconds=tDiff/100"
set /a Percentage=100
%@SET_S:?=Index%
%@SET_S:?=Seconds%
%@TITLE%
if defined Progress_Bar (
    echo:
)
echo  └ [INFORMATION] Finished downloading the !Results_Valid!/!Index! cached URL!s_Index! in !Seconds! second!s_Seconds!.
if exist "Results\!DATETIME!\data_1\" (
    start /max "" "Results\!DATETIME!\data_1"
)

:FINISHED
title !TITLE!
echo:
<nul set /p=.!\B! ■ [INFORMATION] Press {ANY KEY} to exit...
>nul pause
exit /b 0

:FORM_VALID_FILE_NAME
set name=
set ext=
set try=0
for %%A in ("!dst!") do (
    set "name=%%~nA"
    set "ext=%%~xA"
)
:_FORM_VALID_FILE_NAME
set /a try+=1
if exist "Results\!DATETIME!\data_1\!folder!\!name! (!try!)!ext!" (
    goto :_FORM_VALID_FILE_NAME
)
set "dst=!name! (!try!)!ext!"
exit /b
