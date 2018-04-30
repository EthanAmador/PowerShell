# Usage:  powershell ExportSchema.ps1 "SERVERNAME" "DATABASE" "C:\<YourOutputPath>"


# Start Script
Set-ExecutionPolicy RemoteSigned

# Set-ExecutionPolicy -ExecutionPolicy:Unrestricted -Scope:LocalMachine
function GenerateDBScript(
		[string]$username
	   ,[string]$password
	   ,[string]$serverName
	   ,[string]$dbname
	   ,[string]$scriptpath
	   ,[string]$filespath)
{
  [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
  [System.Reflection.Assembly]::LoadWithPartialName("System.Data") | Out-Null
  $srv = new-object "Microsoft.SqlServer.Management.SMO.Server" $serverName
  
  #esto es nuevo
  if(![string]::IsNullOrEmpty($username) -AND ![string]::IsNullOrEmpty($password))
  {
  	$srv.ConnectionContext.LoginSecure = $FALSE
  	$srv.ConnectionContext.Login = $username
  	$srv.ConnectionContext.Password = $password
  }
  
  $srv.SetDefaultInitFields([Microsoft.SqlServer.Management.SMO.View], "IsSystemObject")
  $db = New-Object "Microsoft.SqlServer.Management.SMO.Database"
  $db = $srv.Databases[$dbname]
  $scr = New-Object "Microsoft.SqlServer.Management.Smo.Scripter"
  $deptype = New-Object "Microsoft.SqlServer.Management.Smo.DependencyType"
  $scr.Server = $srv
  $options = New-Object "Microsoft.SqlServer.Management.SMO.ScriptingOptions"
  $options.AllowSystemObjects = $false
  $options.IncludeDatabaseContext = $true
  $options.IncludeIfNotExists = $false
  $options.ClusteredIndexes = $true
  $options.Default = $true
  $options.DriAll = $true
  $options.Indexes = $true
  $options.NonClusteredIndexes = $true
  $options.IncludeHeaders = $false
  $options.ToFileOnly = $true
  $options.AppendToFile = $true
  $options.ScriptDrops = $false 

  # Set options for SMO.Scripter
  $scr.Options = $options
  
  $files = $null

#region Tables
<#
  #=============
  # Tables
  #=============
  $options.FileName = $scriptpath + "\$($dbname)_tables.sql"
  New-Item $options.FileName -type file -force | Out-Null
  Foreach ($tb in $db.Tables)
  {
   If ($tb.IsSystemObject -eq $FALSE)
   {
    $smoObjects = New-Object Microsoft.SqlServer.Management.Smo.UrnCollection
    $smoObjects.Add($tb.Urn)
    $scr.Script($smoObjects)
   }
  }
#>
#endregion

#region Views 
<#
  #=============
  # Views
  #=============
  $options.FileName = $scriptpath + "\$($dbname)_views.sql"
  New-Item $options.FileName -type file -force | Out-Null
  $views = $db.Views | where {$_.IsSystemObject -eq $false}
  Foreach ($view in $views)
  {
    if ($views -ne $null)
    {
     $scr.Script($view)
   }
  }
#>
#endregion

#region StoredProcedures

  #=============
  # StoredProcedures
  #=============
  
  #
  [string[]]$files = GetListFile $filespath
  
  # obtiene los procedimientos almacenados 
  $StoredProcedures = $db.StoredProcedures | where {$_.IsSystemObject -eq $false}
  foreach($sp in $StoredProcedures){
  	# crea el nombre del archivo
  	[string]$fileName = [string]::Concat($sp.Schema,".",$sp.Name,".sql") 
	# verifica que los archivos coincidan 
	[string] $_name = $files | where {$_ -eq $fileName}
	
	if(![string]::IsNullOrEmpty($_name))
	{
		# crea el cuerpo del archivo
		$fileText = [string]::Concat($sp.TextHeader,$sp.TextBody)
  		# crea el archivo 
		New-Item -Path $scriptpath -Name $fileName -Value $fileText -Type file -Force | Out-Null
	}
  }
#endregion

#region Functions
<#
  #=============
  # Functions
  #=============
  $UserDefinedFunctions = $db.UserDefinedFunctions | where {$_.IsSystemObject -eq $false}
  $options.FileName = $scriptpath + "\$($dbname)_functions.sql"
  New-Item $options.FileName -type file -force | Out-Null
  Foreach ($function in $UserDefinedFunctions)
  {
    if ($UserDefinedFunctions -ne $null)
    {
     $scr.Script($function)
   }
  } 
#>
#endregion

#region DBTriggers
<#
  #=============
  # DBTriggers
  #=============
  $DBTriggers = $db.Triggers
  $options.FileName = $scriptpath + "\$($dbname)_db_triggers.sql"
  New-Item $options.FileName -type file -force | Out-Null
  foreach ($trigger in $db.triggers)
  {
    if ($DBTriggers -ne $null)
    {
      $scr.Script($DBTriggers)
    }
  }
#>
#endregion

#region Table Triggers
<#
  #=============
  # Table Triggers
  #=============
  $options.FileName = $scriptpath + "\$($dbname)_table_triggers.sql"
  New-Item $options.FileName -type file -force | Out-Null
  Foreach ($tb in $db.Tables)
  {     
    if($tb.triggers -ne $null)
    {
      foreach ($trigger in $tb.triggers)
      {
        $scr.Script($trigger)
      }
    }
  }
#>
#endregion

}

function GetListFile([string]$filesPath)
{
	$items = Get-ChildItem -Path $filesPath | where {$_.extension -eq ".sql"}
	return $items
}

#=============
# Execute
#=============
## TEST
 #GenerateDBScript "sa" "facture.abc123$" "D08" "zf-elcayao-pro201712030600" "C:\lol_destino" "C:\lol"

GenerateDBScript $args[0]<#NOMBRE USUARIO#> $args[1]<#CONTRASEÑA#> $args[2]<#SERVIDOR#> $args[3]<#NOMBRE BASE DATOS#> $args[4]<#CARPETA DESTINO#> $args[5] <#CARPETA ORIGEN#>