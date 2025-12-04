@echo off
cd /d c:\Users\it\Downloads\pozmixal\postily\apps\frontend
rmdir .next /s /q 2>nul
echo Building frontend...
call pnpm run build > build_output.txt 2>&1
echo Build complete
type build_output.txt
