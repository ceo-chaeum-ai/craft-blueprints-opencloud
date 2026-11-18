; Chaeum Drive installer, modified by ChaeumAI Inc. on 2026-11-18 from Craft's NullsoftInstaller.nsi:
; Unicode, Korean pages and texts, Malgun Gothic, side and header images,
; start menu page skipped (shortcuts go to the start menu root), finish page starts the app without elevation.
Unicode true
; Copyright 2010 Patrick Spendrin <ps_ml@gmx.de>
; Copyright 2016 Kevin Funk <kfunk@kde.org>
; Copyright Hannah von Reth <vonreth@kde.org>
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions
; are met:
; 1. Redistributions of source code must retain the above copyright
;    notice, this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
;
; THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
; OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
; SUCH DAMAGE.

; registry stuff
!define regkey "Software\@{company}\@{productname}"
!define uninstkey "Software\Microsoft\Windows\CurrentVersion\Uninstall\@{productname}"

BrandingText "(주)채움AI"

;--------------------------------

XPStyle on
ManifestDPIAware true


Name "@{productname}"
Caption "@{productname} 설치"

OutFile "@{setupname}"

!define MULTIUSER_EXECUTIONLEVEL Highest
!define MULTIUSER_MUI
!define MULTIUSER_INSTALLMODE_COMMANDLINE
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_KEY "${regkey}"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME "Install_Mode"
!define MULTIUSER_INSTALLMODE_INSTDIR "@{productname}"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_KEY "${regkey}"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_VALUENAME "Install_Dir"

;Start Menu Folder Page Configuration
Var StartMenuFolder
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "SHCTX"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${regkey}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"

;!define MULTIUSER_USE_PROGRAMFILES64
@{multiuser_use_programfiles64}
;!define MULTIUSER_USE_PROGRAMFILES64

@{nsis_include_internal}
@{nsis_include}

!include "MultiUser.nsh"
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"
!include "chaeum-process.nsh"
!include "WordFunc.nsh"

Function SnoreWinVer
    ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
    ${VersionCompare} "6.2" $R0 $R0
    ${If} $R0 == 1
        Push "NotWin8"
    ${Else}
        Push "AtLeastWin8"
    ${EndIf}
FunctionEnd

!macro SnoreShortcut path exe appID
    Call SnoreWinVer
    Pop $0
    ${If} $0 == "AtLeastWin8"
    ${AndIf} "@{SnoreToastExe}" != ""
    ${AndIf} ${FileExists} "@{SnoreToastExe}";did we install snoretoast
        nsExec::ExecToLog '"@{SnoreToastExe}" -install "${path}" "${exe}" "${appID}"'
    ${Else}
        CreateShortCut "${path}" "${exe}"
    ${EndIf}
!macroend

;!define MUI_ICON
@{installerIcon}
!define MUI_UNICON "@{icon}"
;!define MUI_ICON

!define MUI_WELCOMEFINISHPAGE_BITMAP "@{chaeum_side_bitmap}"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "@{chaeum_side_bitmap}"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP "@{chaeum_header_bitmap}"
!define MUI_HEADERIMAGE_UNBITMAP "@{chaeum_header_bitmap}"
!define MUI_ABORTWARNING
!define MUI_ABORTWARNING_TEXT "설치를 그만두시겠습니까?"

!define MUI_WELCOMEPAGE_TITLE "채움드라이브 설치"
!define MUI_WELCOMEPAGE_TEXT "채움드라이브를 이 PC에 설치합니다.$\r$\n$\r$\n설치를 마치면 계정으로 로그인해 클라우드 파일을 PC 폴더처럼 쓸 수 있습니다.$\r$\n$\r$\n채움드라이브가 열려 있으면 설치 중에 닫힙니다."

!insertmacro MUI_PAGE_WELCOME

;!insertmacro MUI_PAGE_LICENSE
@{license}
;!insertmacro MUI_PAGE_LICENSE

;!insertmacro MUI_FINISHPAGE_SHOWREADME
@{readme}
;!insertmacro MUI_FINISHPAGE_SHOWREADME

!define MULTIUSER_INSTALLMODEPAGE_TEXT_TOP "채움드라이브를 누가 쓸지 고르십시오."
!define MULTIUSER_INSTALLMODEPAGE_TEXT_ALLUSERS "이 PC의 모든 사용자 (관리자 권한 필요)"
!define MULTIUSER_INSTALLMODEPAGE_TEXT_CURRENTUSER "나만 쓰기"
!insertmacro MULTIUSER_PAGE_INSTALLMODE
!insertmacro MUI_PAGE_DIRECTORY
!define MUI_PAGE_CUSTOMFUNCTION_PRE ChaeumSkipStartMenu
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder

!define MUI_COMPONENTSPAGE_NODESC
;!insertmacro MUI_PAGE_COMPONENTS
@{sections_page}
;!insertmacro MUI_PAGE_COMPONENTS

!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!define MUI_FINISHPAGE_TITLE "설치를 마쳤습니다"
!define MUI_FINISHPAGE_TEXT "채움드라이브를 열어 계정을 연결하면 파일 동기화가 시작됩니다."
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "채움드라이브 열기"
!define MUI_FINISHPAGE_RUN_FUNCTION ChaeumRunApp
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "Korean"
LangString MULTIUSER_TEXT_INSTALLMODE_TITLE ${LANG_KOREAN} "사용자 선택"
LangString MULTIUSER_TEXT_INSTALLMODE_SUBTITLE ${LANG_KOREAN} "채움드라이브를 설치할 사용자를 고릅니다."
; the language file asks for Gulim, use the current Windows UI font instead
SetFont "맑은 고딕" 9

; shortcuts are created in the start menu root, so the folder page only fills the registry value
Function ChaeumSkipStartMenu
    StrCpy $StartMenuFolder "@{productname}"
    Abort
FunctionEnd

; the installer may run elevated, start the app as the signed-in user through Explorer
Function ChaeumRunApp
    Exec '"$WINDIR\explorer.exe" "$INSTDIR\@{chaeum_exe}"'
FunctionEnd

SetDateSave on
SetDatablockOptimize on
CRCCheck on
SilentInstall normal

Function .onInit
    !insertmacro MULTIUSER_INIT
    !if "@{architecture}" == "x86_64"
        ${IfNot} ${RunningX64}
            MessageBox MB_OK|MB_ICONEXCLAMATION "이 설치 프로그램은 64비트 Windows에서만 실행됩니다."
            Abort
        ${EndIf}
    !endif
FunctionEnd

Function un.onInit
    !insertmacro MULTIUSER_UNINIT
FunctionEnd

;--------------------------------

AutoCloseWindow false


; beginning (invisible) section
Section
  !insertmacro EndProcessWithDialog
  ExecWait '"$MultiUser.InstDir\uninstall.exe" /S _?=$MultiUser.InstDir'
  @{preInstallHook}
  WriteRegStr SHCTX "${regkey}" "Install_Dir" "$INSTDIR"
  WriteRegStr SHCTX "${MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_KEY}" "${MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME}" "$MultiUser.InstallMode"
  ; write uninstall strings
  WriteRegStr SHCTX "${uninstkey}" "DisplayName" "@{productname}"
  WriteRegStr SHCTX "${uninstkey}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegStr SHCTX "${uninstkey}" "DisplayIcon" "$INSTDIR\@{iconname}"
  WriteRegStr SHCTX "${uninstkey}" "URLInfoAbout" "@{website}"
  WriteRegStr SHCTX "${uninstkey}" "Publisher" "@{company}"
  WriteRegStr SHCTX "${uninstkey}" "DisplayVersion" "@{version}"
  WriteRegDWORD SHCTX "${uninstkey}" "EstimatedSize" "@{estimated_size}"

  @{registry_hook}

  SetOutPath $INSTDIR


; package all files, recursively, preserving attributes
; assume files are in the correct places

File /a "@{dataPath}"
File /a "@{7za}"
File /a "@{icon}"
nsExec::ExecToLog '"$INSTDIR\7za.exe" x -r -y "$INSTDIR\@{dataName}" -o"$INSTDIR"'
Delete "$INSTDIR\7za.exe"
Delete "$INSTDIR\@{dataName}"

AddSize @{installSize}

WriteUninstaller "uninstall.exe"

SectionEnd

; create shortcuts
@{shortcuts}

;  allow to define additional sections
@{sections}


; Uninstaller
; All section names prefixed by "Un" will be in the uninstaller

UninstallText "@{productname}을(를) 이 PC에서 제거합니다. PC 폴더의 파일은 지우지 않습니다."

Section "Uninstall"
!insertmacro EndProcessWithDialog

DeleteRegKey SHCTX "${uninstkey}"
DeleteRegKey SHCTX "${regkey}"

!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
RMDir /r "$SMPROGRAMS\$StartMenuFolder"

@{uninstallFiles}
@{uninstallDirs}

SectionEnd

;  allow to define additional Un.sections
@{un_sections}
