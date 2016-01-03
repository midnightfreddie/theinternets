# https://www.reddit.com/r/PowerShellChallenge/comments/3ywz6a/challenge_january_2016/
# Part 2

function Invoke-PowerCSV {
    param (
        $ComputerName,
        $InputFile,
        $UpdateValue
    )
    Import-Csv $InputFile |
        Where-Object { $_.ComputerName -eq $ComputerName } |
        ForEach-Object {
            $FirstValue, $NewValues =  @(
                $_.psobject.Properties |
                    Where-Object { $_.Name -ne "ComputerName" } |
                    Select-Object -ExpandProperty Value
                $UpdateValue
            )
            
            $NewValues
        }
}

Invoke-PowerCSV -ComputerName "Mercury" -UpdateValue 999 -InputFile "C:\Users\jim.AD\SkyDrive\Documents\Powershell\theinternets\Challenge1.csv"