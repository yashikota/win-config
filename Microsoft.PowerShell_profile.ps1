Invoke-Expression (&starship init powershell)
Import-Module posh-git
Import-Module PSReadLine

# Starship
$ENV:STARSHIP_CONFIG = "$HOME\Documents\Powershell\starship.toml"

# OSC 133 shell integration for Windows Terminal (enables Ctrl+Shift+C to copy previous output)
if ($env:WT_SESSION) {
    $script:__PromptExecuting = $null
    $script:__OriginalPrompt = $function:prompt

    function global:prompt {
        $exitCode = if ($global:?) { 0 } else { $global:LASTEXITCODE }
        if ($null -eq $exitCode) { $exitCode = 0 }

        if ($null -ne $script:__PromptExecuting) {
            [Console]::Write("`e]133;D;${exitCode}`a")
        }

        [Console]::Write("`e]133;A`a")

        $promptText = & $script:__OriginalPrompt

        $script:__PromptExecuting = $true

        "${promptText}`e]133;B`a"
    }

    Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
        [Console]::Write("`e]133;C`a")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}

# Key bindings
Set-PSReadLineKeyHandler -Key Ctrl+k -Function ShellKillWord
Set-PSReadLineKeyHandler -Key Ctrl+u -Function ShellBackwardKillWord
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit

# Aliases
Invoke-Expression (& { (zoxide init powershell | Out-String) })

function Invoke-EzaLs {
    eza -la --icons --color=always --git --time-style relative
}
Set-Alias ls Invoke-EzaLs

function Invoke-EzaTree {
    eza --tree --icons --color=always --git --time-style relative
}
Set-Alias tree Invoke-EzaTree

function grep {
    rg @args
}

function less {
    bat
}

function which { (Get-Command $args).Definition }

function .. {
    Set-Location ..
}

# uutils
if (Get-Command coreutils -ErrorAction SilentlyContinue) {
    $excluded_commands = @("ls", "cat", "cd", "less")
    $coreutilsExe = (Get-Command coreutils.exe).Source
    $all_commands = (coreutils --list) -replace '\[|\]' -split "`n" |
        Where-Object { $_ -match '\w+' } |
        ForEach-Object { $_.Trim() }

    foreach ($command in $all_commands) {
        if ($excluded_commands -notcontains $command) {
            $function_definition = "function global:$command { & '$coreutilsExe' $command `$args }"
            Invoke-Expression $function_definition
        }
    }
}
