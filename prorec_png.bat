@echo off

set "ffmpeg_cmd=ffmpeg -loglevel error -stats -framerate "-fps-^" -i ^"-inputdirectory-^" -c:v utvideo -y ^"-outputdirectory-^".avi"
set fps=600
set "format=ffmpeg_cmd"


setlocal EnableDelayedExpansion

if [%1]==[] (
    echo Please drag the folder containing your image sequences onto the .bat file
    goto :exit
)

set current_dir=%1
set "current_dir_name=%~n1"
cd !current_dir!

echo %cd%

call :image_check img_exist
call :folder_check folder_exist

if !folder_exist!==0 if !img_exist!==0 goto no_encode
if !folder_exist!==1 if !img_exist!==1 goto ask_type
if !folder_exist!==1 goto batch_encode
if !img_exist!==1 (
    call :encode_folder
    goto exit
)

REM ask for encode_type
:ask_type
echo Found images and folders in the current directory
set /p encode_type="Encode current directory images(0) or encode all folders(1)?"
if !encode_type!==1 goto batch_encode
if !encode_type!==0 (
    call :encode_folder
    goto exit
)
if !encode_type!==exit goto exit
echo Invalid Input!
goto ask_type

:batch_encode
echo Batch Encode:
for /f "delims==" %%D in ('dir /a:d /b') do (
    call :encode_folder "%%D"
)
goto exit


:no_encode
echo Found nothing to encode. Make sure the image sequences are in folders or in the directory you dragged in.

goto exit

:exit
echo END
pause
exit

:folder_check
set %~1=0

for /f "delims=" %%D in ('dir /a:d /b') do (
    set %~1=1
    exit /b
)
exit /b

:image_check
set %~1=0

if exist *.png set %~1=1
if exist *.jpg set %~1=1
if exist *.tga set %~1=1
exit /b

REM 1 - input dir, 2 - outputdir, 3 - fps, 4 - format
:encode_file
set currentformat=!%~4!
call set currentformat=%%currentformat:-inputdirectory-=%~1%%
call set currentformat=%%currentformat:-outputdirectory-=%~2%%
call set currentformat=%%currentformat:-fps-=%~3%%
set currentformat=!currentformat:[hash]=%%!
!currentformat!
exit /b

:encode_folder
cd !current_dir!
if not ["%~1"]==[""] (
   set "parent_dir=%~1"
   pushd %~1
)
if ["%~1"]==[""] (
    set "parent_dir=!current_dir_name!"

)
call :image_check img_exist
if !img_exist!==0 exit /b
for %%a in (*.png, *.jpeg, *.tga) do (
    set "current_name=%%a"
    set "file_extension=%%~xa"
    goto found_name
)
:found_name
cd ..
echo %cd%
for /f "delims=_" %%i in ("%current_name%") do ( set "sequence_name=%%i")

call :encode_file "!parent_dir!\!sequence_name!_[hash]d!file_extension!", "!sequence_name!_!parent_dir!", "!fps!", "!format!"

exit /b