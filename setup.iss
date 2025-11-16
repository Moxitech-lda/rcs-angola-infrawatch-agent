; Script de Inno Setup para Flutter Windows + C# App

[Setup]
AppName=AgentInfraWatch
AppVersion=1.0
DefaultDirName={pf}\RCS_Angola
DefaultGroupName=RCS_Angola
UninstallDisplayIcon={app}\agent_infra_watch.exe
OutputDir=Output
OutputBaseFilename=AgentInfraWatch
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar atalho no Desktop"; GroupDescription: "Atalhos:"; Flags: unchecked

[Files]
; Flutter Windows
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

; C# Executáveis/DLLs
Source: "iwa_server\bin\Debug\net9.0\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
[Icons]
Name: "{group}\AgentInfraWatch"; Filename: "{app}\agent_infra_watch.exe"
Name: "{userdesktop}\AgentInfraWatch"; Filename: "{app}\agent_infra_watch.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\agent_infra_watch.exe"; Description: "Executar AgentInfraWatch"; Flags: nowait postinstall skipifsilent