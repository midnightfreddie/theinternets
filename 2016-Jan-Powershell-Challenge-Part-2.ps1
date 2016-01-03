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
            $Values = $_.psobject.Properties | Where-Object { $_.Name -ne "ComputerName" }

            $FirstValue, $NewValues =  @(
                $Values | Select-Object -ExpandProperty Value
                $UpdateValue
            )

            $NewValues
            $Values.Length
            0..($Values.Length - 1) | ForEach-Object {
                $Values[$_].Value = $NewValues[$_]
                #$Values[$_].Value
                #$NewValues[$_]
                #"Hi"

            }
            $_
        } #|
        #Export-Csv -NoTypeInformation $InputFile
}

Invoke-PowerCSV -ComputerName "Mercury" -UpdateValue 999 -InputFile "C:\Users\jim.AD\SkyDrive\Documents\Powershell\theinternets\Challenge1.csv"