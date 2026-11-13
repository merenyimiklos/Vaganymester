; VÁGÁNYMESTER Windows Installer, 64-bit, .NET runtime included
#define MyAppName "VÁGÁNYMESTER"
#define MyAppVersion "0.1.0"
#define MyExe "Vaganymester.exe"

[Setup]
AppId={{C6B18F23-857F-4DAB-B4EA-0699E683D852}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion} – tesztverzió
AppPublisher=VÁGÁNYMESTER
AppPublisherURL=https://github.com/merenyimiklos/Vaganymester
AppSupportURL=https://github.com/merenyimiklos/Vaganymester/issues
AppUpdatesURL=https://github.com/merenyimiklos/Vaganymester/releases
DefaultDirName={localappdata}\Programs\VAGANYMESTER
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
DisableWelcomePage=no
AllowNoIcons=yes
PrivilegesRequired=lowest
UsePreviousAppDir=yes
UsePreviousTasks=yes
UninstallDisplayIcon={app}\{#MyExe}
UninstallDisplayName={#MyAppName}
Compression=lzma2/max
SolidCompression=yes
OutputDir=..\artifacts\installer
OutputBaseFilename=Vaganymester-Windows-Setup
SetupIconFile=assets\vaganymester.ico
WizardStyle=modern dark
WizardImageFile=assets\wizard.png
WizardSmallImageFile=assets\wizard-small.png
WizardImageStretch=yes
WizardSizePercent=120,120
WizardResizable=no
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
CloseApplications=yes
RestartApplications=no
ShowLanguageDialog=auto
VersionInfoVersion=0.1.0.0
VersionInfoDescription=VÁGÁNYMESTER – Windows telepítő
VersionInfoProductName=VÁGÁNYMESTER
VersionInfoCompany=VÁGÁNYMESTER
SetupLogging=yes

[Languages]
Name: "hungarian"; MessagesFile: "compiler:Languages\Hungarian.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\artifacts\publish\*"; DestDir: "{app}"; Excludes: "*.pdb,*.dbg"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyExe}"; WorkingDir: "{app}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyExe}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyExe}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent
