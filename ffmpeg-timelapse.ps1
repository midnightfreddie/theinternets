# Script in reply to reddit question "Help for a script for converting many timelapses to thumbnail videos via ffmpeg?"
# https://www.reddit.com/r/PowerShell/comments/3duoy8/help_for_a_script_for_converting_many_timelapses/

# Pass this script the -ForReal switch to actually run the ffmpeg command
# Pass in the correct parameters or edit the defaults below
# An empty $DestPath will cause output mpgs to go to the same folder where the input jpgs are

[cmdletbinding()]
param (
    $ffmpeg = "C:\tools\ffmpeg-20150720-git-9ebe041-win64-static\bin\ffmpeg.exe",
    $RootFolder = "C:\Temp\pics",
    $DestPath = "C:\Temp\videos",
    [switch] $ForReal
)

# Moved the ffmpeg call here so it's easy to find and edit command-line flags
filter Out-FfmpegFile {
    param (
        # Apparently filters can't have mandatory parameters?
        #[Parameter(Mandatory = $true)]
        $ffmpeg,
        [switch]$PassThru,
        $ForReal = $false
    )

    Write-Verbose "File spec: $($_.InputFileSpec)"
    Write-Verbose "Output Filename: $($_.OutputFileName)"

    # Currently it will show a lot of red, but that's because ffmpeg is chatty.
    # If running more than once, realize that ffmpeg will stop if the output file already exists

    if ($ForReal) {
        Write-Verbose "Running ffmpeg"
        &$ffmpeg  -f image2 -c:v mjpeg -i "$($_.InputFileSpec)" "$($_.OutputFileName)"
    } else {
        Write-Verbose "Not running ffmpeg because `$ForReal not true"
    }

    if ($Passthru) { $_ }
}    
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
            # Images = $Images
            # Assumes counters are zero-padded four digit; e.g. 0001, 0002, 0003 . Change %04d to %03d or whatnot for different number of digit padding
            InputFileSpec = $Images[0] -replace '(\d+)(\.jpe?g)$', '%04d$2'
            OutputFileName = $OutputFileName
        }
    }
}

function Get-Href {
    param (
        $Link
    )
    "<a href=""{0}"">{1}</a>" -f $Link, $Link.Split("\/")[-1]
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

# Beginning of script.
$BaseIndexFileName = "$DestPath\$((Get-Date -Format s).Replace(":", "-"))-output"
Get-Folders -RootFolder $RootFolder |
    Get-FfmpegCommands -DestPath $DestPath |
    Out-FfmpegFile -ffmpeg $ffmpeg -PassThru -ForReal $ForReal |
    # ConvertTo-Json | Out-File -Encoding utf8 -FilePath "$BaseIndexFileName.json"
    # Export-Csv -NoTypeInformation -Path "$BaseIndexFileName.csv"
    ConvertTo-Html | Out-File -Encoding utf8 -FilePath "$BaseIndexFileName.html"

    # This doesn't quite work like I want. The links "download" the file.
    # ConvertTo-Html | ForEach-Object { $_ -replace '(<td>)([^<]+)(</td></tr>)', '$1<a href="$2">$2</a>$3' } | Out-File -Encoding utf8 -FilePath "$BaseIndexFileName.html"

    # To catch any piped output to avoid an error due to commenting/uncommenting stuff
    ForEach-Object { $_ }
