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
# ls
function l {
    eza -la --icons --git --time-style relative
}
# which
function which { (Get-Command $args).Definition }
