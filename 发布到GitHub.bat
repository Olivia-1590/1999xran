@echo off
chcp 65001 >nul
title 发布 叠叠乐 到 GitHub
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0push-ddl.ps1"
echo.
pause
