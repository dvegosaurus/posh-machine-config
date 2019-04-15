function config-service 
{
    [cmdletbinding()]
    param(
        [validatescript({get-service $_})]
        [parameter(mandatory=$true,position=0)]
        [string]$name,
        [Validateset('automatic','boot','disabled','manual','system')]
        [parameter(mandatory=$true,position=1)]
        [string]$StartType
    )
    
    $list = @(
        'disabled',
        'manual'
    )

    Set-Service -Name $name -StartupType $StartType
    if ($StartType -in $list){Stop-Service $name}
    else {Start-Service $name}
} # config-service 

function config-regvalue 
{
    [cmdletbinding()]
    param(
        [parameter(mandatory=$true,position=0)]
        [string]$path,
        [Validateset('set','clear','delete')]
        [parameter(mandatory=$true,position=1)]
        [string]$action,
        [parameter(mandatory=$true,position=2)]
        [string]$name,
        [parameter(position=3)]
        [string]$value,
        [Validateset('REG_SZ','REG_DWORD')]
        [parameter(position=4)]
        [string]$regtype
    )

    switch ($regtype)
    {
        "REG_SZ"    {$type = "string"}
        "REG_DWORD" {$type = "dWord"}
    }
    switch ($action)
    {
        "set"     {Set-ItemProperty     -Path $path -Name $name -Value $value}
        "clear"   {Set-ItemProperty     -Path $path -Name $name -Value ''}
        "delete"  {Remove-ItemProperty  -Path $path -Name $name}
        "create"  
        {
            if (!(Test-Path $path)){New-Item $path -ItemType Directory}
            New-ItemProperty -Path $path -Name $name -Value $value -PropertyType $type
        }
    }
} # config-regvalue 

function config-folder 
{
    [cmdletbinding()]
    param(
        [parameter(mandatory=$true,position=0)]
        [string]$path,
        [Validateset('clear','delete','rename','create')]
        [parameter(mandatory=$true,position=1)]
        [string]$action
    )

    switch ($action)
    {
        "rename"  {if (!(Test-Path $path)){Rename-Item $path $name }}
        "clear"   {Get-ChildItem -Recurse -Path $path | foreach {remove-item -Path $_.FullName -Force}}
        "delete"  {Remove-Item  -Path $path -Force -Recurse}
        "create"  {if (!(Test-Path $path)){New-Item $path -ItemType Directory}}
    }
} # config-folder 
