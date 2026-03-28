Set objArgs = WScript.Arguments
Dim folderPath
If objArgs.Count > 0 Then
    folderPath = objArgs(0)
Else
    folderPath = ""
End If

' Запуск PowerShell GUI скрипта без консолі
Set objShell = CreateObject("WScript.Shell")
psCmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File ""D:\rename_folders\rename_folders.ps1"" """ & folderPath & """"
objShell.Run psCmd, 0, False