Invoke-Expression (&starship init powershell)
Import-Module posh-git
Import-Module PSReadLine

# Starship
$ENV:STARSHIP_CONFIG = "$HOME\Documents\Powershell\starship.toml"

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
