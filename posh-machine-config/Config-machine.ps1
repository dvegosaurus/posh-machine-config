$confpath = "$PSScriptRoot\conf\testconf.conf"
Import-Module "$PSScriptRoot\functions\functions.psm1"


# load the test configuration
$list = Get-Content $confpath | ConvertFrom-Json


# select item tagged as apply
$itemtoapply = $list | where {$_.apply -or $_.apply -eq $null}

# foreach item execute the proper function to configure it
foreach ($item in $itemtoapply)
{
    switch ($item.type)
    {
        "service"   {config-service $item.name $item.StartType}
        "registry" 
                    {
                        if ($item.value){config-regvalue -path $item.path -name $item.name -value $item.value -action $item.action}
                        else {config-regvalue -path $item.path -name $item.name -action $item.action}
                        if ($item.action -match "create"){config-regvalue -path $item.path -name $item.name -value $item.value -action $item.action -regtype $item.regtype}
                    }
        "folder"    {config-folder  -path $item.path -action $item.action }
        "file"      {config-file    -path $item.path -action $item.action }

    }
}