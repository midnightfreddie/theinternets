# https://www.reddit.com/r/PowerShellChallenge/comments/3ywz6a/challenge_january_2016/

function Invoke-PowerCSV {
    param (
        $ComputerName,
        $InputFile
    )
    Import-Csv $InputFile |
        Where-Object { $_.ComputerName -eq $ComputerName } |
        ForEach-Object {
            $_.psobject.Properties |
                Where-Object { $_.Name -ne "ComputerName" } |
                ForEach-Object {
                    $_.Value
                }
        }
}

Invoke-PowerCSV -ComputerName "Mercury" -InputFile "C:\Users\jim.AD\SkyDrive\Documents\Powershell\theinternets\Challenge1.csv"