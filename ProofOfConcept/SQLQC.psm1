# Version = 1.1 Testing
# Date = 18/12/13
# Early proff of concept example of code written when I was a Windows Sys Add at Rackspace for SQL checks as part of QA process.  Written outside of work.

# Get-Command -Module SQLQC

# Example run comandline:

# Import-Module -DisableNameChecking ".\SQLQC.psm1" -Force
# Import-Module -DisableNameChecking "c:\rs-pkgs\SQLQC.psm1" -Force
# Start-SQLQC
#
# Start-SQLQC -SQLServInst 502668-C1SQL1\CLUSTERINSTANCE1 -MaxMem 3 -Set -Get

#############TSQL Functions#############

Function Set-DBRecoveryModel{
Param(
     [Parameter(Mandatory=$False)] [String] $RecoveryModel,
     [Parameter(Mandatory=$False)] [String] $Database
     )

$TSQL = ""
$TSQL = @"
--Set database recovery model.
ALTER DATABASE $Database SET RECOVERY $RecoveryModel
GO
"@

Write-Debug "Set-DBRecoveryModel"

Return $TSQL
}

Function Set-SQLMaxMemory {
    param (
        [parameter(Mandatory = $true)][int64] $MaxMemMB
    )

$TSQL = ""
$TSQL = @"
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'max server memory', $MaxMemMB;
GO
RECONFIGURE;
GO
sp_configure 'show advanced options', 0;
GO
RECONFIGURE;
GO
"@

Return $TSQL
}

Function Set-TempDBFiles{

$TSQL = ""
$TSQL = @"
CREATE TABLE #numprocs
(
[Index] INT,
[Name] VARCHAR(200),
Internal_Value VARCHAR(50),
Character_Value VARCHAR(200)
)
DECLARE @BASEPATH VARCHAR(200)
DECLARE @PATH VARCHAR(200)
DECLARE @SQL_SCRIPT VARCHAR(500)
DECLARE @CORES INT
DECLARE @FILECOUNT INT
DECLARE @SIZE INT
DECLARE @GROWTH INT
DECLARE @ISPERCENT INT
INSERT INTO #numprocs
EXEC xp_msver
SELECT @CORES = Internal_Value FROM #numprocs WHERE [Index] = 16
IF @CORES > 8
BEGIN
  SET @CORES = 8
END
PRINT @CORES
SET @BASEPATH = (select SUBSTRING(physical_name, 1, CHARINDEX(N'tempdb.mdf', LOWER(physical_name)) - 1) DataFileLocation
					FROM master.sys.master_files
					WHERE database_id = 2 and FILE_ID = 1)
PRINT @BASEPATH
SET @FILECOUNT = (SELECT COUNT(*)
					FROM master.sys.master_files
					WHERE database_id = 2 AND TYPE_DESC = 'ROWS')
SELECT @SIZE = size FROM master.sys.master_files WHERE database_id = 2 AND FILE_ID = 1
SET @SIZE = @SIZE / 128
SELECT @GROWTH = growth FROM master.sys.master_files WHERE database_id = 2 AND FILE_ID = 1
SELECT @ISPERCENT = is_percent_growth FROM master.sys.master_files WHERE database_id = 2 AND FILE_ID = 1
WHILE @CORES > @FILECOUNT
BEGIN
	SET @SQL_SCRIPT = 'ALTER DATABASE tempdb
	ADD FILE
	(
		FILENAME = ''' + @BASEPATH + 'tempdb' + RTRIM(CAST(@CORES as CHAR)) + '.ndf'',
		NAME = tempdev' + RTRIM(CAST(@CORES as CHAR)) + ',
		SIZE = ' + RTRIM(CAST(@SIZE as CHAR)) + 'MB,
		FILEGROWTH = ' + RTRIM(CAST(@GROWTH as CHAR))
	IF @ISPERCENT > 0
		SET @SQL_SCRIPT = @SQL_SCRIPT + '%'
	SET @SQL_SCRIPT = @SQL_SCRIPT + ')'
EXEC(@SQL_SCRIPT)
	SET @CORES = @CORES - 1
END
DROP TABLE #numprocs
"@

Write-Debug "Set-TempDBFiles"

Return $TSQL
}

Function Get-DBFiles {
param (
        [parameter(Mandatory = $true)][String] $DBName
    )

$TSQL = ""
$TSQL = @"
--List $DBName files.
USE $DBName
SELECT
physical_name AS [$DBName File Path] FROM sys.database_files
GO
"@

Write-Debug "Get-DBFiles"

Return $TSQL
}

Function Get-DBRecoveryModel{
Param(
     [Parameter(Mandatory=$False)] [String] $Database
     )

$TSQL = ""
$TSQL = @"
--Recovery model of the $Database database.
SELECT '$Database' AS [Database Name],
DATABASEPROPERTYEX('model', 'RECOVERY')
AS [Recovery model]
GO
"@

Write-Debug "Get-TSQL-ModelDBtoSimple"

Return $TSQL
}

Function Get-SQLMaxMemory{
$TSQL = ""
$TSQL = @"
SELECT name, value, value_in_use, [description]
FROM sys.configurations WHERE name = 'max server memory (MB)'
GO
"@

Write-Debug "Get-TSQL-MaxMemory"

Return $TSQL
}

Function Get-InventorySQL{

$TSQL = ""
$TSQL = @"
--Check SQL version.
SELECT
@@version AS [SQL Server Version],
SERVERPROPERTY('ProductLevel') AS ProductLevel,
SERVERPROPERTY('Edition') AS Edition,
SERVERPROPERTY('EngineEdition') AS EngineEdition;
GO
SELECT
SERVERPROPERTY ('MachineName') AS MachineName,
SERVERPROPERTY ('InstanceName') AS InstanceName,
SERVERPROPERTY ('Collation') AS Collation;
GO
--Get configuration value 'max server memory'
SELECT name, value, value_in_use, [description]
FROM sys.configurations WHERE name = 'max server memory (MB)'
GO
--Recovery model of the model database.
SELECT 'model' AS [Database Name],
DATABASEPROPERTYEX('model', 'RECOVERY')
AS [Recovery model]
GO
--List TempDB files.
USE tempdb
SELECT
physical_name AS [TempDB File Path] FROM sys.database_files
GO
--Clustering, FullTextIndex, AllwaysOn.
SELECT
'1=Installed, 0= Not Installed, NULL=Not Applicable' AS [Key],
SERVERPROPERTY ('IsClustered') AS [Clustered],
SERVERPROPERTY ('IsFullTextInstalled') AS [FullText Installed],
SERVERPROPERTY ('IsHadrEnabled') AS [AlwaysOn (SQL2012+)];
GO
--Default file locations.
declare @datadir nvarchar(4000)
        ,@logdir nvarchar(4000);
EXEC master.dbo.xp_instance_regread
    N'HKEY_LOCAL_MACHINE'
    , N'Software\Microsoft\MSSQLServer\MSSQLServer'
    , N'DefaultData'
    , @datadir output;
IF @datadir IS NULL
BEGIN
EXEC master.dbo.xp_instance_regread
    N'HKEY_LOCAL_MACHINE'
    , N'Software\Microsoft\MSSQLServer\Setup'
    , N'SQLDataRoot'
    , @datadir output;
END
EXEC master.dbo.xp_instance_regread
    N'HKEY_LOCAL_MACHINE'
    , N'Software\Microsoft\MSSQLServer\MSSQLServer'
    , N'DefaultLog'
    , @logdir output;
SELECT @datadir AS 'SQL default DATA location', ISNULL(@logdir,@datadir) AS 'SQL default LOG location';
--Get SQL TCP/IP port used from registry.
DECLARE @TcpPort VARCHAR(5)
        ,@RegKey VARCHAR(100)
IF @@SERVICENAME !='MSSQLSERVER'
BEGIN
SET @RegKey = 'SOFTWARE\Microsoft\Microsoft SQL Server\' + @@SERVICENAME + '\MSSQLServer\SuperSocketNetLib\Tcp'
END
ELSE
BEGIN
SET @RegKey = 'SOFTWARE\MICROSOFT\MSSQLSERVER\MSSQLSERVER\SUPERSOCKETNETLIB\TCP'
END
EXEC master..xp_regread
@rootkey = 'HKEY_LOCAL_MACHINE'
,@key = @RegKey
,@value_name = 'TcpPort'
,@value = @TcpPort OUTPUT
SELECT @TcpPort AS [SQL TCP Port]
GO
"@
Write-Debug "Get-InventorySQL"

Return $TSQL
}

##############TSQL Functions#############

Function Get-SQLQCBanner {

$Background = "Black"

($String = @"

   .oooooo..o   .oooooo.      ooooo             .oooooo.        .oooooo.
  d8P.    \Y8  d8P.  \Y8b     \888.            d8P.  \Y8b      d8P.  \Y8b
  Y88bo.      888      888     888            888      888    888
   \iY8888o.  888      888     888            888      888    888
       \iY88b 888      888     888            888      888    888
  oo     .d8P \88b    d88b     888       o    \88b    d88b    \88b    ooo
  8ii88888P.   \Y8bood8P.Ybd. o888ooooood8     \Y8bood8P.Ybd.  \Y8bood8P.

  Ver 1.1

"@)[0..$String.Length] | Out-Null
For ($i=0; $i -lt $String.Length;$i++)
{
switch ($String[$i])
    {
    "." {Write-host $String[$i] -foreground Yellow -background $Background -nonewline}
	"\" {Write-host $String[$i] -foreground Blue -background $Background -nonewline}
	"o" {Write-host $String[$i] -foreground Green -background $Background -nonewline}
	"i" {Write-host $String[$i] -foreground Cyan -background $Background -nonewline}
	"d" {Write-host $String[$i] -foreground Cyan -background $Background -nonewline}
	"8" {Write-host $String[$i] -foreground Red -background $Background -nonewline}
	"P" {Write-host $String[$i] -foreground Magenta -background $Background -nonewline}
	"Y" {Write-host $String[$i] -foreground Yellow -background $Background -nonewline}
	"b" {Write-host $String[$i] -foreground Yellow -background $Background -nonewline}
	' ' {Write-host $String[$i] -foreground White -background $Background -nonewline}
	default {Write-host $String[$i] -foreground White -background $Background -nonewline}
    }
}
Write-Host " "
}

Function Get-Memory {

$InstalledMemory = gwmi -query "SELECT Capacity FROM  Win32_PhysicalMemory"

foreach ($InstallMem in $InstalledMemory)
{
    $Capacity = $Capacity + $InstallMem.Capacity
}

$Capacity = $Capacity / 1GB
$Capacity = [Math]::Round($Capacity, 2)

return $Capacity
}

Function Import-SQLSnapin {

# SQL Snapin registered on the system.
#Write-Host "(!(!(Get-PSSnapin -registered | ?{$_.name -eq 'SqlServerCmdletSnapin100'}))) = " (!(!(Get-PSSnapin -registered | ?{$_.name -eq 'SqlServerCmdletSnapin100'})))

If(!(!(Get-PSSnapin -registered | ?{$_.name -eq 'SqlServerCmdletSnapin100'})))
    {
    #SQL Snapin is loaded
	#Write-Host "(!(!(Get-PSSnapin | ?{$_.name -eq 'SqlServerCmdletSnapin100'}))) = " (!(!(Get-PSSnapin | ?{$_.name -eq 'SqlServerCmdletSnapin100'})))
	If (!(!(Get-PSSnapin | ?{$_.name -eq 'SqlServerCmdletSnapin100'})))
        {
		Write-Host "SQL Snapin (SqlServerCmdletSnapin100) Already Loaded." -foreground Green
		}
    Else
        {
        #Attempting to load SqlServerCmdletSnapin100 - windows 2008 R2 and below.
        Write-Host "Loading SQL Snapin (SqlServerCmdletSnapin100) in session" -foreground Green
        Add-pssnapin SqlServerCmdletSnapin100

        #Write-Host "(!(!(Get-PSSnapin | ?{$_.name -eq 'SqlServerCmdletSnapin100'}))) = " (!(!(Get-PSSnapin | ?{$_.name -eq 'SqlServerCmdletSnapin100'})))
            If (!(!(Get-PSSnapin | ?{$_.name -eq 'SqlServerCmdletSnapin100'})))
                #Checking if SQL Snapin is now loaded
                {
                Write-Host "SQL Snapin (SqlServerCmdletSnapin100) Loaded." -foreground Green
                }
            Else
                {
                Write-Host "SQL Snapin (SqlServerCmdletSnapin100) Failed to Load. Exiting code." -foreground Red
                break
                }
		}

    }
Else
    {
        #SQL Snapin is not registered on server e.g. SQL not installed.
        Write-host "SQL Snapin (SqlServerCmdletSnapin100) not present on local server." -foreground Red
        Write-host "Snapin is not pressent on windows 2012, only 2008 R2 and below. Will try loading SQLPS module." -foreground Yellow
        #Checking if SQLPS module is present
	#Write-Host "(!(!(Get-Module | where {$_.name -eq 'sqlps'}))) = " (!(!(Get-Module | where {$_.name -eq 'sqlps'})))

        If(!(!(Get-Module | where {$_.name -eq 'sqlps'})))
			{
            #module present
            Write-Host "Importing PowerShell Module SQLPS." -foreground Green
            Import-Module 'sqlps'  DisableNameChecking
			}
        Else
			{
            #module not present
            Write-host "PowerShell Module SQLPS not present on local server." -foreground Red
            Write-host "Check SQL is installed on server your running this script on?" -foreground Red
   		break
            }
        }
Write-Host " "
Write-Debug "Import-SQLSnapin"
}

Function Test-SQLConnection {
    param (
        [Parameter(Mandatory=$False)] [Array] $SQLServInst,
        [parameter(Mandatory = $false)][Int] $TimeOut = 1
    )

    $TestResult = $false

    try
    {
        $SqlDB = "master"
        $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $SqlConnection.ConnectionString = "Server = $SQLServInst; Database = $SqlDB; Integrated Security = True; Connection Timeout=$TimeOut"
        $SqlConnection.Open()
        $TestResult = $SqlConnection.State -eq "Open"
    }

    catch
    {
    }

    finally
    {
        $SqlConnection.Close()
    }

    Return $TestResult

Write-Debug "Test-SQLConnection"
}


Function Invoke-TSQL {
Param(
     [Parameter(Mandatory=$True)][string] $TSQL,
     [Parameter(Mandatory=$True)][array] $SQLServInst,
     [Parameter(Mandatory=$False)][switch] $TSQLVerbose
     )

$invokedebug = @"
Invoke-SqlCmd -Query "$TSQL" -ServerInstance "$SQLServInst"
"@
Write-Verbose $invokedebug`n

If ($TSQLVerbose)
    {
    #If true this command uses the -verbos switch at end of the line. Usefull if TSQL uses print command or T-SQL is erroring.
    $SQLOutput = Invoke-SqlCmd -Query "$TSQL" -ServerInstance "$SQLServInst"  -Verbose
    }
Else
    {
    #Default is to use this one currently
    $SQLOutput = Invoke-SqlCmd -Query "$TSQL" -ServerInstance "$SQLServInst"
    }

Return $SQLOutput

Write-Debug "Invoke-Function"
}

Function Get-SQLInstances {

Write-Host "Discovering SQL instances (may take several seconds)..." -foreground Green
$SQLManObjects = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo");
$SQLManObjects.Location
if (!$SQLManObjects.Location)
	{
	Write-Host "SQL Management objects not loaded. Exiting." -foreground Red
	Break
	}
Else
    {
$DiscoveredSQL = @()
$DiscoveredSQL = [Microsoft.SqlServer.Management.Smo.SmoApplication]::EnumAvailableSqlServers($false) | Select name;
Write-Host "...Discovery  Complete" -foreground Green
	}

Write-Debug "Get-SQLInstances"

Return $DiscoveredSQL
}

Function Get-InstanceMenu {
Param(
     [Parameter(Mandatory=$False)] [Array] $SQLServInsts
     )

Write-Host `n"Discovered SQL Instances"
Write-Host "-------------------------"`n

If (!$SQLServInsts[1].Name)
    {
	Write-Host "No SQL instances Found." -ForegroundColor Red
	Break
	}
Else
	{
	For ($i=1; $i -lt $SQLServInsts.Length;$i++)

		{
		Write-Host "    $i - Name =" $SQLServInsts[$i].Name

		}
	}

$iM1 = $i - 1
$Option = Read-Host `n"Select instance/s option e.g. 1 .. $iM1 ?"
$SelectedInstance = $SQLServInsts[$Option].Name

Write-Debug "Get-InstanceMenu"

Return $SelectedInstance
}

Function Set-SQLQC {
Param(
     [Parameter(Mandatory=$True)][int64] $MaxMem,
     [Parameter(Mandatory=$True)][array] $SQLServInst
     )


Write-Verbose "SQLServInst = $SQLServInst"
Write-Verbose "MaxMem = $MaxMem"

Write-Host "Modifying SQL Settings on Server $SQLServInst"`n -ForegroundColor Green

$MaxMem = $MaxMem * 1GB
$MaxMemMB = $MaxMem / 1MB


If (!$MaxMemMB -or $MaxMemMB -lt 128)
    {
    Write-Host "Value for Max Memory specified is empty or less than 1GB e.g. $MaxMemMB MB. Skipping setting Max Memory." -ForegroundColor Red
    }
Else
    {
    Write-Host "Max Memory will be set to = $MaxMemMB MB"
    Write-Host "Setting Max Memory...."

    $TSQL = ""
    $Output = ""
    $TSQL = Set-SQLMaxMemory -MaxMemMB $MaxMemMB
    $Output = Invoke-TSQL -TSQL $TSQL -SQLServInst $SQLServInst

    Write-Host "...Complete"`n
    }

#Sets Number of Temp DB files per core.

Write-Host "Setting TempDB files per proc/core...."

$TSQL = ""
$Output = ""
$TSQL = Set-TempDBFiles
$Output = Invoke-TSQL -TSQL $TSQL -SQLServInst $SQLServInst

Write-Host "...Complete"`n

#Sets Module DB Recovery Model to Simple.

Write-Host "Setting Module DB Recovery Model to Simple...."

$TSQL = ""
$Output = ""
$TSQL = Set-DBRecoveryModel -Database Model -RecoveryModel SIMPLE
$Output = Invoke-TSQL -TSQL $TSQL -SQLServInst $SQLServInst

Write-Host "...Complete"`n

Write-Debug "Set-SQLQC"
}

Function Get-SQLQC {
Param(
     [Parameter(Mandatory=$True)][array] $SQLServInst
     )

Write-Host "Display SQL server settings $SQLServInst" -ForegroundColor Green

$TSQL = Get-InventorySQL
$Output = Invoke-TSQL -TSQL $TSQL -SQLServInst $SQLServInst
$Output | FL

Write-Debug "Get-SQLQC"
}

Function Start-SQLQC {
<#
.Synopsis
   Main Function that runs the SQL Quality Check functions against the Selected/Specified SQL instance.
.DESCRIPTION
   Main function that either runs an inventory of SQL server Selected/specified (-Get) or Configures SQL server select/specified (-Set).
   This script is designed to be run from the Server or Node your QCing.

   For the purpose of either auditing (-get) or setting (-set):

    1.) Model DB recovery model to simple.
    2.) Number of TempDB files per Processor cores.
    3.) Setting SQL Max Memory.

    Note: This is achieved by executing T-SQL from PowerShell against the SQL server instance specified.
.EXAMPLE
   Start-SQLQC

   Running the command with no switches will run it interactively prompting for input.
   It will also automatically use both -set and -get parameters, setting SQL settings and inventorying SQL settings.
   Also it will discover SQL instances on the local network.
.EXAMPLE
   Start-SQLQC -Get

   Running the command with Get switch will run it interactively prompting for input.
   It will return the settings of SQL server without making any changes to SQL.
.EXAMPLE
   Start-SQLQC -Set

   Running the command with only the Set switch will run it interactively prompting for input.
   It will configure SQL without returning the SQL server settings.
.EXAMPLE
   Start-SQLQC -SQLServInst <ServerName\SQLInstanceName> -MaxMem <Max Memory Size in GB> -Set -Get

   Running the command with all switches above will execute without prompting for input.
   This method of running the script will execute the fastest as you are not prompted for input and SQL instance discovery is not required.
.INPUTS

   -SQLServInst <ServerName\SQLInstanceName>

   Script checks if the instance exists by attempting to open a connection to SQL.  If it fails the script will quit.
   If switch is not specified the code will discover SQL instances on the network which can take anywhere from 5 to 30 seconds.
   Then display the instances found and prompts for a selection.

   -MaxMem <Max Memory Size in GB>
Max memory size in GB.  There are checks in place me to make sure max memory is not set to 0 as this will break SQL and require the start-up parameters to be changed to get SQL up and running again.

   -Set
   Configures SQL.

   -Get
	Inventorys SQL settings.

   Note: If Neither -Get or -Set are specified the scripts defaults are or run both.
.NOTES
   This script is a first draft and is currently in testing phase (11/12/13).
.COMPONENT
   Module SQLQC.psm1

#>
Param(
     [Parameter(Mandatory=$False)][int64] $MaxMem,
     [Parameter(Mandatory=$False)][array] $SQLServInst,
	 [Parameter(Mandatory=$False)][Switch] $Get,
	 [Parameter(Mandatory=$False)][Switch] $Set,
     [Parameter(Mandatory=$False)][String] $WriteDebug,
     [Parameter(Mandatory=$False)][String] $WriteVerbose
     )

#############Debug/Verbose#############
Switch ($WriteDebug)
    {
    I { $DebugPreference = "Inquire"; break}
    S { $DebugPreference = "SilentlyContinue"; break}
    C { $DebugPreference = "Continue"; break}
    Default { $DebugPreference = "SilentlyContinue"}
    }

Switch ($WriteVerbose)
    {
    I { $VerbosePreference = "Inquire"; break}
    S { $VerbosePreference = "SilentlyContinue"; break}
    C { $VerbosePreference = "Continue"; break}
    Default { $VerbosePreference = "SilentlyContinue"}
    }
#############Debug/Verbose#############

Get-SQLQCBanner

If ($psversiontable.psversion.major -lt 2)
    {
    Write-Host "Powershell version $PSver installed.  Powershell 2.0 reqiured. Exiting script." -forgroundcolor Red
    Break
    }
Else
    {
    Write-verbose "Powershell version $PSver installed."
    }

Write-Host "This script is designed to be run from the Server or Node your QCing.
For the purpose of either auditing or setting:
1.) Model DB recovery model to simple.
2.) Number of TempDB files per Processor cores.
3.) Setting SQL Max Memory.
Note: This is achieved by executing T-SQL from PowerShell against the SQL server instance specified.`n" -ForegroundColor Yellow

Import-SQLSnapin

If (!$SQLServInst)
    {
    Write-Host "No SQL instances details provided"

	$DiscoveredSQL = Get-SQLInstances

	Write-Debug "Var test"

    Write-Verbose "DiscoveredSQL = $DiscoveredSQL"

    $SQLServInst = Get-InstanceMenu -SQLServInst $DiscoveredSQL
    }

$Capacity = Get-Memory
$Name = gc env:computername

If (!$SQLServInst)
    {
    Write-Host "No SQL instances details provided" -ForegroundColor Red
    Break
    }
Else
    {
	$TestResult = Test-SQLConnection -SQLServInst $SQLServInst
    If ($TestResult -eq 'True')
        {
        Write-Host ""
		Write-Host "Connection to SQL instance $SQLServInst Successful"`n -ForegroundColor Green

        If ($set -and !$get)
            {

		If (!$MaxMem)
				{
				$Capacity = Get-Memory
				$Name = gc env:computername

				Write-Host "Local Server $Name Has $Capacity GB of Memory installed." -ForegroundColor Yellow
				Write-Verbose "No Value Provided for Max Memory"
				$MaxMem = Read-Host "Enter Max Memory value specified in Imp Doc in GB e.g. 4?"
				}

            Set-SQLQC -SQLServInst $SQLServInst -MaxMem $MaxMem
            }
        ElseIf ($get -and !$set)
            {
			Get-SQLQC -SQLServInst $SQLServInst
            }
        Else
            {
		If (!$MaxMem)
				{
				$Capacity = Get-Memory
				$Name = gc env:computername

				Write-Host "Local Server $Name Has $Capacity GB of Memory installed." -ForegroundColor Yellow
				Write-Verbose "No Value Provided for Max Memory"
				$MaxMem = Read-Host "Enter Max Memory value specified in Imp Doc in GB e.g. 4?"
				}

            Set-SQLQC -SQLServInst $SQLServInst -MaxMem $MaxMem
            Get-SQLQC -SQLServInst $SQLServInst
            }

        }
	Else
	    {
    	Write-Host "Connection to SQL instance $SQLServInst Failed. Exiting." -ForegroundColor Red
        Break
	    }

    }
Write-Debug "Start-SQLQC"
}
