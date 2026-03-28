# =========================================
# Rename Folders GUI — працює із контекстного меню
# =========================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

param(
    [string]$root
)

if (-not $root -or -not (Test-Path $root)) {
    $root = $PSScriptRoot
}

# --- Форма ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Перейменування папок"
$form.Size = New-Object System.Drawing.Size(800,500)
$form.StartPosition = "CenterScreen"

# --- Поле шляху ---
$textPath = New-Object System.Windows.Forms.TextBox
$textPath.Location = New-Object System.Drawing.Point(10,10)
$textPath.Size = New-Object System.Drawing.Size(600,20)
$textPath.Text = $root
$form.Controls.Add($textPath)

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text = "..."
$btnBrowse.Location = New-Object System.Drawing.Point(620,8)
$btnBrowse.Add_Click({
    $f = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($f.ShowDialog() -eq "OK") {
        $textPath.Text = $f.SelectedPath
    }
})
$form.Controls.Add($btnBrowse)

# --- Поля заміни ---
$textOld = New-Object System.Windows.Forms.TextBox
$textOld.Location = New-Object System.Drawing.Point(10,40)
$textOld.Size = New-Object System.Drawing.Size(200,20)
$textOld.PlaceholderText = "Що замінити"
$form.Controls.Add($textOld)

$textNew = New-Object System.Windows.Forms.TextBox
$textNew.Location = New-Object System.Drawing.Point(220,40)
$textNew.Size = New-Object System.Drawing.Size(200,20)
$textNew.PlaceholderText = "На що замінити"
$form.Controls.Add($textNew)

# --- Кнопки ---
$btnPreview = New-Object System.Windows.Forms.Button
$btnPreview.Text = "Перевірити"
$btnPreview.Location = New-Object System.Drawing.Point(450,38)
$form.Controls.Add($btnPreview)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "Виконати"
$btnRun.Location = New-Object System.Drawing.Point(560,38)
$form.Controls.Add($btnRun)

# --- Таблиця ---
$list = New-Object System.Windows.Forms.ListView
$list.Location = New-Object System.Drawing.Point(10,80)
$list.Size = New-Object System.Drawing.Size(760,350)
$list.View = "Details"
$list.FullRowSelect = $true
$list.GridLines = $true

[void]$list.Columns.Add("Було", 350)
[void]$list.Columns.Add("Стане", 350)

$form.Controls.Add($list)

# --- Функція заповнення таблиці ---
function Load-Preview {
    $list.Items.Clear()

    $root = $textPath.Text
    $old  = $textOld.Text
    $new  = $textNew.Text

    if (-not (Test-Path $root)) {
        [System.Windows.Forms.MessageBox]::Show("Невірний шлях!")
        return
    }

    if ($old -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Введи текст для заміни!")
        return
    }

    Get-ChildItem -Path $root -Directory -Recurse |
    Sort-Object FullName -Descending |
    ForEach-Object {
        if ($_.Name -like "*$old*") {
            $newName = $_.Name -replace [regex]::Escape($old), $new

            $item = New-Object System.Windows.Forms.ListViewItem($_.FullName)
            $item.SubItems.Add((Join-Path $_.Parent.FullName $newName))

            $list.Items.Add($item)
        }
    }

    if ($list.Items.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Нічого не знайдено.")
    }
}

# --- Кнопка "Перевірити" ---
$btnPreview.Add_Click({ Load-Preview })

# --- Кнопка "Виконати" ---
$btnRun.Add_Click({

    if ($list.Items.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Спочатку натисни 'Перевірити'")
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Виконати перейменування?",
        "Підтвердження",
        [System.Windows.Forms.MessageBoxButtons]::YesNo
    )

    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    $root = $textPath.Text
    $old  = $textOld.Text
    $new  = $textNew.Text

    Get-ChildItem -Path $root -Directory -Recurse |
    Sort-Object FullName -Descending |
    ForEach-Object {
        if ($_.Name -like "*$old*") {
            $newName = $_.Name -replace [regex]::Escape($old), $new
            Rename-Item -Path $_.FullName -NewName $newName
        }
    }

    [System.Windows.Forms.MessageBox]::Show("Готово!")
    Load-Preview
})

# --- Запуск форми ---
$form.Topmost = $true
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()