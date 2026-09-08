@echo off
REM ================================================================
REM RELEASE BUILD -- WITH DART OBFUSCATION (added 2026-09-06)
REM ================================================================
REM
REM Run this from the flutter_application_1 (customer app) project
REM root instead of a plain "flutter build appbundle --release". The
REM Android-side R8 shrinking/obfuscation in build.gradle.kts only
REM covers the native Kotlin/Java glue -- Flutter's own Dart code
REM needs its OWN separate --obfuscate flag, which strips human-
REM readable class/function names from your actual app logic before
REM it ships.
REM
REM --split-debug-info writes the symbol map needed to turn a garbled
REM obfuscated stack trace back into a readable one. KEEP THAT FOLDER
REM SOMEWHERE SAFE AND PRIVATE (not in git) for every release you
REM ship -- without it, a crash report from an obfuscated build is
REM permanently unreadable, even to you.

echo Building release App Bundle with obfuscation...
echo.

flutter clean
if errorlevel 1 goto :error

flutter pub get
if errorlevel 1 goto :error

flutter build appbundle --release --obfuscate --split-debug-info=build\app\outputs\symbols
if errorlevel 1 goto :error

echo.
echo ================================================================
echo  Done. App Bundle:
echo    build\app\outputs\bundle\release\app-release.aab
echo.
echo  Debug symbols (KEEP THESE PRIVATE, back them up outside git):
echo    build\app\outputs\symbols\
echo ================================================================
goto :eof

:error
echo.
echo Build failed -- see the error above.
exit /b 1
