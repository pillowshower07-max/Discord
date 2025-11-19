@echo off
echo ====================================
echo ProtectedRTC Publisher
echo ====================================
echo.

echo Cleaning previous build...
rmdir /s /q bin\Release 2>nul
rmdir /s /q publish 2>nul

echo.
echo Publishing application...
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -p:EnableCompressionInSingleFile=true

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo Creating distribution folder...
mkdir publish 2>nul
xcopy /E /I /Y bin\Release\net8.0-windows\win-x64\publish publish\

echo.
echo ====================================
echo SUCCESS! Your application is ready!
echo ====================================
echo.
echo Location: desktop-client\publish\ProtectedRTC.exe
echo.
echo You can now:
echo 1. Test it by running: publish\ProtectedRTC.exe
echo 2. Share the entire 'publish' folder with friends
echo 3. Or create an installer (see DISTRIBUTION_GUIDE.md)
echo.
pause
