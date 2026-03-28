Set objArgs = WScript.Arguments
Dim folderPath
If objArgs.Count > 0 Then
    folderPath = objArgs(0)
Else
    folderPath = ""
End If

' Запуск PowerShell GUI скрипта без консолі
Set objShell = CreateObject("WScript.Shell")
Dim fso, scriptDir, ps1Path, psCmd
Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
ps1Path = scriptDir & "\rename_folders.ps1"

psCmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File """ & ps1Path & """ """ & folderPath & """"
objShell.Run psCmd, 0, False
