@echo off
setlocal
cd /d c:\Users\it\Downloads\pozmixal\postily\apps\frontend
echo Building frontend...
call pnpm run build
if %ERRORLEVEL% EQU 0 (
    echo Build successful!
    if exist .next\static\chunks (
        echo Chunk directory found - build appears complete
    )
) else (
    echo Build failed with error code %ERRORLEVEL%
)
