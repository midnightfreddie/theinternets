# Script in reply to reddit question "Help for a script for converting many timelapses to thumbnail videos via ffmpeg?"
# https://www.reddit.com/r/PowerShell/comments/3duoy8/help_for_a_script_for_converting_many_timelapses/

#$ffmpeg = "C:\tools\ffmpeg-2.5.2-win64-shared\bin\ffmpeg.exe"
$ffmpeg = "C:\tools\ffmpeg-20150720-git-9ebe041-win64-static\bin\ffmpeg.exe"
$RootFolder = "C:\Temp\pics"
$DestFolder = "C:\Temp\videos"
    
# Pipe a stream of folders to this and get an object with the jpgs in that folder and some other info
filter Get-FfmpegCommands {
    $Images = Get-ChildItem $_.Fullname |
            Where-Object { -not $_.PsIsContainer } |
            Where-Object { $_.Name -imatch '\.jpe?g$'} |
            Select-Object -ExpandProperty FullName
        
    if ($Images -ne $null) {
        New-Object psobject -Property @{
            Images = $Images
            PathFullName = $_.FullName
            PathName = $_.Name
            OutputFileName = $Images[0].Split("\/")[-1] -replace '-?(\d+)?\.jpe?g$', '.mpg'
        }
    }
}
    
# Given a folder, returns a stream of folders including this one and all recursive subfolders
function Get-Folders {
    param (
        [Parameter(Mandatory = $true)]
        $RootFolder
    )
    Get-Item $RootFolder
    Get-ChildItem -Recurse -Path $RootFolder |
        Where-Object { $_.PsIsContainer }
}
    

# Beginning of script. 
Get-Folders -RootFolder $RootFolder |
    Get-FfmpegCommands |
    ForEach-Object {

        # Use this one to put the videos in $DestFolder
        $outfilename = "$DestFolder\$($_.OutputFilename)"

        # Use this to put the videos in the path with the images
        #$outfilename = "$($_.PathFullName)\$($_.OutputFilename)"

        # UNCOMMENT THE FOLLOWING LINE when you're ready to try for real
        # Currently it will show a lot of red, but that's because ffmpeg is chatty.
        # If running more than once, realize that ffmpeg will stop if the output file already exists
        Get-Content -Raw $_.Images | &$ffmpeg  -f image2pipe -c:v mjpeg -i - $outfilename

        # This is just to see the output objects
        $_ | Format-List
    }
