# Author    : Mark Hall
# Objective : Build a simple maths game for a child who likes trains
# Date      : 12/11/2014

#Set the Powershell windows configuration.
$pshost = get-host
$pswindow = $pshost.ui.rawui

$pswindow.windowtitle = "Powershell - BBcode"

$newsize = $pswindow.buffersize
$newsize.height = 1000
$newsize.width = 120
$pswindow.buffersize = $newsize

$newsize = $pswindow.windowsize
$newsize.height = 45
$newsize.width = 120
$pswindow.windowsize = $newsize

Clear-host

Function DrawTrain($Carriages,$Carriages2)
{

#ASCII
#############
$Smoke = @"

              ______________________________________
       ______/ - _________  -- ___________   --    ---
     _/ ________/  ------ \___/_____ -   ---  -----
    // /_________ \_______________________ -------   --
    / \ /         \______________________________
"@

#Engine
$Engine1 = @"
   ____
"@

$Engine2 = @"
   \  /  _
"@

$Engine3 = @"
   _||_.|_|
"@

$Engine4 = @"
 /|       |
"@

$Engine5 = @"
/_|-0----0'
"@

#Carriages
$Carrage1 = @"
 |"""""|
"@

$Carrage2 = @"
_|     |
"@

$Carrage3 = @"
 '-0-0-'
"@

#############

#$Carriages = 2

$Colour = "Cyan"

#Smoke
Write-Host $Smoke -ForegroundColor Gray

#Engine + Carriages
Write-Host $Engine1 -ForegroundColor Magenta;
Write-Host $Engine2 -ForegroundColor Magenta;
Write-Host $Engine3 -ForegroundColor Magenta -NoNewline;Write-Host ($Carrage1 * $Carriages) -ForegroundColor $Colour -NoNewline; Write-Host "   +   " -ForegroundColor White -NoNewline; Write-Host ($Carrage1 * $Carriages2) -ForegroundColor $Colour;
Write-Host $Engine4 -ForegroundColor Magenta -NoNewline;Write-Host ($Carrage2 * $Carriages) -ForegroundColor $Colour -NoNewline; Write-Host "  +++  " -ForegroundColor White -NoNewline; Write-Host ($Carrage2 * $Carriages2) -ForegroundColor $Colour;
Write-Host $Engine5 -ForegroundColor Magenta -NoNewline;Write-Host ($Carrage3 * $Carriages) -ForegroundColor $Colour -NoNewline; Write-Host "   +   " -ForegroundColor White -NoNewline; Write-Host ($Carrage3 * $Carriages2) -ForegroundColor $Colour;

}

Function Question ($Carriages,$Carriages2)
{

Write-Host "`nThe Train has " -NoNewline;
Write-Host "$Carriages" -NoNewline -ForegroundColor Cyan;
Write-Host " carrage and another " -NoNewline;
Write-Host "$Carriages2" -NoNewline -ForegroundColor Cyan;
Write-Host " carriage are going to be added, how many carriages will the train then have?"
}

$Array = "1,2","2,4","2,1","7,2","1,1","1,7","5,4","3,7","9,2"

[int]$Score = 0
[int]$Number = 0

ForEach ($Item in $Array)
{
    $Number ++
    Clear-Host

    $Split = $item.Split(",")
    [int]$int0 = $Split[0]
    [int]$int1 = $Split[1]

    Write-Host "`n`n Question?`n`n"
    DrawTrain -Carriages $int0  -Carriages2 $int1
    Question -Carriages $int0  -Carriages2 $int1
    $Answer = Read-Host " ";

    $2ndTry = $null

    If ($Answer -eq ($int0 + $int1))
    {
        Write-Host "`n Correct Answer" -ForegroundColor Green
        $Score ++
    }
    Else
    {
        Write-Host "`nWrong Answer" -ForegroundColor Red
        $2ndTry = $True
    }

    If ($2ndTry)
    {
        Write-Host "`nUnlucky, please try again.`n"

        Question -Carriages $int0 -Carriages2 $int1
        $Answer = Read-Host " ";

        If ($Answer -eq ($int0 + $int1))
        {
            Write-Host "`n Well Done thats a correct Answer" -ForegroundColor Green
            $Score ++
        }
        Else
        {
            Write-Host "`n Unlucky, incorrect" -ForegroundColor Red
            Write-Host "`n The Answer to : $int0 + $int1 =" ($int0 + $int1) -ForegroundColor Green
        }
    }
    Write-Host "Press any key to continue ..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Clear

Write-Host "`n`n You scored $Score out of $Number  Well done." -ForegroundColor Cyan

DrawTrain -Carriages 5 -Carriages2 5

Write-Host "`n`n You scored $Score out of $Number  Well done." -ForegroundColor Cyan
