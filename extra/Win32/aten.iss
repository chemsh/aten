; Script generated by the Inno Script Studio Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Aten"
#define MyAppVersion "1.99.0"
#define MyAppPublisher "Tristan Youngs"
#define MyAppURL "http://www.projectaten.net/"
#define MyAppExeName "Aten.exe"

#define QtDir "C:\Qt\5.4.1\qtbase\bin"
#define GnuWin32Dir "C:\GnuWin32\bin"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{8DF93A4D-C712-41C4-B8EE-75484080B32F}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\Aten2
DefaultGroupName={#MyAppName}
LicenseFile=..\COPYING
OutputDir=..\
OutputBaseFilename=Aten-1.99.0
SetupIconFile=Aten.ico
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

[Files]
Source: "..\build\bin\Aten.exe"; DestDir: "{app}/bin"; Flags: ignoreversion
Source: "..\data\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: "{#GnuWin32Dir}\freetype6.dll"; DestDir: "{app}/bin"
Source: "{#GnuWin32Dir}\readline5.dll"; DestDir: "{app}/bin"
Source: "{#GnuWin32Dir}\history5.dll"; DestDir: "{app}/bin"
Source: "{#GnuWin32Dir}\zlib1.dll"; DestDir: "{app}/bin"
Source: "C:\MinGW32\bin\libgcc_s_dw2-1.dll"; DestDir: "{app}/bin"
Source: "C:\MinGW32\bin\libstdc++-6.dll"; DestDir: "{app}/bin"
Source: "{#QtDir}\Qt5Gui.dll"; DestDir: "{app}/bin"; Flags: ignoreversion
Source: "{#QtDir}\Qt5Core.dll"; DestDir: "{app}/bin"; Flags: ignoreversion
Source: "{#QtDir}\Qt5OpenGL.dll"; DestDir: "{app}/bin"; Flags: ignoreversion
Source: "{#QtDir}\Qt5Svg.dll"; DestDir: "{app}/bin"; Flags: ignoreversion
Source: "{#QtDir}\Qt5Widgets.dll"; DestDir: "{app}/bin"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
