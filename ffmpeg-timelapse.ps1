# Script in reply to reddit question "Help for a script for converting many timelapses to thumbnail videos via ffmpeg?"
# https://www.reddit.com/r/PowerShell/comments/3duoy8/help_for_a_script_for_converting_many_timelapses/

[cmdletbinding()]
param (
    $ffmpeg = "C:\tools\ffmpeg-20150720-git-9ebe041-win64-static\bin\ffmpeg.exe",
    $RootFolder = "C:\Temp\pics",
    $DestFolder = "C:\Temp\videos"
)
    
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
            # Assumes counters are zero-padded four digit; e.g. 0001, 0002, 0003 . Change %04d to %03d or whatnot for different number of digit padding
            InputFileSpec = $Images[0] -replace '(\d+)(\.jpe?g)$', '%04d$2'
        }
    }
}
    
# Given a folder, returns a stream of folders including this one and all recursive subfolders
function Get-Folders {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true)]
        $RootFolder
    )
    Get-Item $RootFolder
    Get-ChildItem -Recurse -Path $RootFolder |
        Where-Object { $_.PsIsContainer }
}

# Moved the ffmpeg call here so it's easy to find and edit command-line flags
function Out-FfmpegFile {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true)] $ffmpeg,
        [Parameter(Mandatory = $true)] $InputFileSpec,
        [Parameter(Mandatory = $true)] $Path
    )
    # Currently it will show a lot of red, but that's because ffmpeg is chatty.
    # If running more than once, realize that ffmpeg will stop if the output file already exists

    &$ffmpeg  -f image2 -c:v mjpeg -i "$InputFileSpec" "$Path"

}

# Beginning of script. 
Get-Folders -RootFolder $RootFolder |
    Get-FfmpegCommands |
    ForEach-Object {
        # Use this one to output to $DestFolder with first-letter of each parent path prepended to output name
        $SubPath = $_.PathFullName.Replace($RootFolder, "")
        $Prefix = (
            $SubPath.Split("\/",[System.StringSplitOptions]::RemoveEmptyEntries) |
                ForEach-Object { $_.ToCharArray()[0] }
        ) -Join "-"
        $outfilename = "$DestFolder\$Prefix-$($_.OutputFilename)"


        # Use this one to put the videos in $DestFolder
        #$outfilename = "$DestFolder\$($_.OutputFilename)"

        # Use this to put the videos in the path with the images
        #$outfilename = "$($_.PathFullName)\$($_.OutputFilename)"

        # This is just to see the output objects
        Write-Verbose "Image set: $($_ | Format-List | Out-String)"

        Write-Verbose "Adjusted Output Filename $outfilename"

        # UNCOMMENT THE FOLLOWING LINE when you're ready to try for real
        # Out-FfmpegFile -ffmpeg $ffmpeg -InputFileSpec $_.InputFileSpec -Path $outfilename
    }
