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
            $Row = $_
            $FirstValue, $NewValues =  @(
                ( $Row.psobject.Properties |
                    Where-Object { $_.Name -ne "ComputerName" } |
                    Select-Object -ExpandProperty Value
                ),
                $UpdateValue
            )

            $NewValues
            #1..$_.psobject.Properties.Length | ForEach-Object {
                
            #}
        } #|
        #Export-Csv -NoTypeInformation $InputFile
}

Invoke-PowerCSV -ComputerName "Mercury" -UpdateValue 999 -InputFile "C:\Users\jim.AD\SkyDrive\Documents\Powershell\theinternets\Challenge1.csv"