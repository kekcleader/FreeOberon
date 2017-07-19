; FreeOberon.nsi
;
; This script is based on example1.nsi, but it remember the directory, 
; has uninstall support and (optionally) installs start menu shortcuts.
;
; It will install FreeOberon.nsi into a directory that the user selects,

;--------------------------------

; The name of the installer
Name "FreeOberon"

; The file to write
OutFile "FreeOberon_Setup.exe"

; The default installation directory
InstallDir $PROGRAMFILES\FreeOberon

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\FreeOberon" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

;--------------------------------

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "FreeOberon (required)"

  SectionIn RO
  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  ; File "FreeOberon.exe"
  File /r "FreeOberon\*"
  
  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\NSIS_FreeOberon "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FreeOberon" "DisplayName" "NSIS FreeOberon"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FreeOberon" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FreeOberon" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FreeOberon" "NoRepair" 1
  WriteUninstaller "uninstall.exe"
  
SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\FreeOberon"
  CreateShortcut "$SMPROGRAMS\FreeOberon\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortcut "$SMPROGRAMS\FreeOberon\FreeOberon.lnk" "$INSTDIR\FreeOberon.exe" "" "$INSTDIR\FreeOberon.exe" 0
  
SectionEnd

; Optional section (can be disabled by the user)
Section "Desktop Shortcut"

  CreateShortcut "$DESKTOP\Free Oberon.lnk" "$INSTDIR\FreeOberon.exe"
  
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FreeOberon"
  DeleteRegKey HKLM SOFTWARE\NSIS_FreeOberon

  ; Remove files and uninstaller
  Delete $INSTDIR\FreeOberon.exe
  Delete $INSTDIR\uninstall.exe
  Delete $INSTDIR\LICENSE
  Delete $INSTDIR\README.md
  Delete $INSTDIR\*.dll
  Delete $INSTDIR\Programs\BlitBmp.Mod
  Delete $INSTDIR\Programs\BlitBmp2.Mod
  Delete $INSTDIR\Programs\Book.Mod
  Delete $INSTDIR\Programs\Gradient24.Mod
  Delete $INSTDIR\Programs\r.Mod
  Delete "$DESKTOP\Free Oberon.lnk"

  ; Remove Free Oberon subdirectories
  RMDir /r /REBOOTOK $INSTDIR\bin
  RMDir /r /REBOOTOK $INSTDIR\data
  RMDir /r /REBOOTOK $INSTDIR\src
  RMDir /r /REBOOTOK $INSTDIR\Programs

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\FreeOberon\*.*"

  ; Remove directories used
  RMDir "$SMPROGRAMS\FreeOberon"
  RMDir /REBOOTOK "$INSTDIR"

SectionEnd
