# Script in reply to reddit question "Help for a script for converting many timelapses to thumbnail videos via ffmpeg?"
# https://www.reddit.com/r/PowerShell/comments/3duoy8/help_for_a_script_for_converting_many_timelapses/

[cmdletbinding()]
param (
    $ffmpeg = "C:\tools\ffmpeg-20150720-git-9ebe041-win64-static\bin\ffmpeg.exe",
    $RootFolder = "C:\Temp\pics",
    $DestFolder = "C:\Temp\videos"
)
    
# Pipe a stream of folders to this and get an object with the jpgs in that folder and some other info
# If $DestPath parameter not provided or "", will output to same folder where jpgs are
filter Get-FfmpegCommands {
    param (
        $DestPath = $null
    )
    $Images = Get-ChildItem $_.Fullname |
        Where-Object { -not $_.PsIsContainer } |
        Where-Object { $_.Name -imatch '\.jpe?g$'} |
        Select-Object -ExpandProperty FullName
        
    if ($Images -ne $null) {

        # Use first-letter of each parent path prepended to output filename
        $SubPath = $_.FullName.Replace($RootFolder, "")
        $Prefix = (
            $SubPath.Split("\/",[System.StringSplitOptions]::RemoveEmptyEntries) |
                ForEach-Object { $_.ToCharArray()[0] }
        ) -Join "-"
        if ($DestPath) {
            $OutputFileName = "$DestPath\$Prefix-$($Images[0].Split("\/")[-1] -replace '-?(\d+)?\.jpe?g$', '.mpg')"
        } else {
            $OutputFileName = "$($_.Fullname)\$Prefix-$($Images[0].Split("\/")[-1] -replace '-?(\d+)?\.jpe?g$', '.mpg')"
        }

        [pscustomobject]@{
            PathFullName = $_.FullName
            PathName = $_.Name
            Images = $Images
            # Assumes counters are zero-padded four digit; e.g. 0001, 0002, 0003 . Change %04d to %03d or whatnot for different number of digit padding
            InputFileSpec = $Images[0] -replace '(\d+)(\.jpe?g)$', '%04d$2'
            OutputFileName = $OutputFileName
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
filter Out-FfmpegFile {
    param (
        # Apparently filters can't have mandatory parameters?
        #[Parameter(Mandatory = $true)]
        $ffmpeg,
        [switch]$Passthru
    )
    # Currently it will show a lot of red, but that's because ffmpeg is chatty.
    # If running more than once, realize that ffmpeg will stop if the output file already exists

    &$ffmpeg  -f image2 -c:v mjpeg -i "$($_.InputFileSpec)" "$($_.OutputFileName)"

    if ($Passthru) { $_ }
}

# Beginning of script. 
Get-Folders -RootFolder $RootFolder |
    Get-FfmpegCommands -DestPath $DestFolder |

    # UNCOMMENT THE FOLLOWING LINE when you're ready to try for real
    # Out-FfmpegFile -ffmpeg $ffmpeg -Passthru |

    Out-Default
