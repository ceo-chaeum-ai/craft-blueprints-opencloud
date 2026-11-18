; Korean copy of Craft's process.nsh, modified by ChaeumAI Inc. on 2026-11-18 (message text only)
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

!define PowerShell "$WINDIR\sysnative\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy ByPass -Command"

Var ProcessList

!macro StopProcess root
    nsExec::ExecToLog '${PowerShell} "&{ Write-Host \"Killing processes in\" (Join-Path \"${root}\" *); Get-Process * | Where-Object { $$_.Path -Like (Join-Path \"${root}\" *) } |  %{ Write-Host \"killing\", $$_.Path; Stop-Process $$_ } }"'
!macroend


!macro ListProcess root
    nsExec::ExecToStack '${PowerShell} "&{ Get-Process * | Where-Object { $$_.Path -Like (Join-Path \"${root}\" *) } |  %{ Write-Host $$_.Path } }"'
    Pop $0
    Pop $1
    StrCpy $ProcessList $1
!macroend


!macro EndProcessWithDialog
IfFileExists $INSTDIR retry_kill
Goto end_kill
retry_kill:
    !insertmacro ListProcess "$INSTDIR"
    ${If} $ProcessList != ""
        MessageBox MB_YESNOCANCEL "다음 프로그램이 실행 중입니다.$\n$ProcessList$\n$\n$\"예$\"를 누르면 닫고 계속합니다. $\"아니요$\"는 다시 확인, $\"취소$\"는 그만둡니다." /SD IDYES IDNO retry_kill IDCANCEL abort_kill
        !insertmacro StopProcess "$INSTDIR"
        Goto retry_kill
        abort_kill:
            Quit
    ${EndIf}
end_kill:
!macroend
