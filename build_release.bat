@echo off
setlocal

echo ========================================
echo   🔧 Build Automático - Projeto Release
echo ========================================

REM Verifica se o Flutter está disponível
where flutter >nul 2>&1
if errorlevel 1 (
    echo [ERRO] Flutter nao encontrado no PATH.
    pause
    exit /b 1
)

REM Verifica se o dotnet está disponível
where dotnet >nul 2>&1
if errorlevel 1 (
    echo [ERRO] .NET SDK nao encontrado no PATH.
    pause
    exit /b 1
)

REM === 1. Build do Flutter (Windows)
echo.
echo 🛠️  Gerando release Flutter (Windows)...
flutter build windows --release
if errorlevel 1 (
    echo [ERRO] Erro ao compilar o projeto Flutter.
    pause
    exit /b 1
)

REM === 2. Build do Projeto .NET
echo.
echo 🛠️  Gerando release .NET Console (iwa_server)...
dotnet publish iwa_server\iwa_server.csproj -c Release
if errorlevel 1 (
    echo [ERRO] Erro ao compilar o projeto .NET.
    pause
    exit /b 1
)

REM === 3. Compilando instalador com Inno Setup
echo.
echo 🧰 Gerando instalador com Inno Setup...

REM Caminho padrão do Inno Setup
set "ISCC_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"

if exist "%ISCC_PATH%" (
    "%ISCC_PATH%" setup.iss
    if errorlevel 1 (
        echo [ERRO] Erro ao gerar o instalador com Inno Setup.
        pause
        exit /b 1
    )
) else (
    echo [ERRO] Inno Setup (ISCC.exe) nao encontrado no caminho padrao:
    echo         %ISCC_PATH%
    echo.
    echo Por favor, edite este .bat e corrija o caminho se necessario.
    pause
    exit /b 1
)

echo.
echo ✅ Build finalizado com sucesso!
pause
endlocal
