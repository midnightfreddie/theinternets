# https://www.reddit.com/r/PowerShellChallenge/comments/3ywz6a/challenge_january_2016/
# Combined Parts 1 and 2

function Invoke-PowerCSV {
    param (
        $ComputerName,
        $InputFile,
        $UpdateValue
    )
    # I would normally pipeline from Import-Csv all the way to output, but since we're
    # updating the input file I have to store the data in a variable to close the input
    # so it can be reopened for writing
    $IHateThisVariable = Import-Csv $InputFile |
        ForEach-Object {
            if ($_.ComputerName -eq $ComputerName) {
                if ($UpdateValue) {
                    # Grab an array of the objects of the values (not ComputerName) in the row
                    # These objects are "live". I can update $Values and the object $_ will be updated
                    $Values = $_.psobject.Properties | Where-Object { $_.Name -ne "ComputerName" }

                    # Cute trick: Multiple assignment. $FirstValue will get the first value of the right-side array
                    #   $NewValues will be an array of the remaining values
                    #   The right side is an array of all the values in the csv with $UpdateValue at the end
                    $FirstValue, $NewValues =  @(
                        $Values | Select-Object -ExpandProperty Value
                        $UpdateValue
                    )

                    # Assign $NewValue elements to $Values which will also update $_
                    0..($Values.Length - 1) | ForEach-Object {
                        $Values[$_].Value = $NewValues[$_]
                    }

                    # Emit the possibly-updated row object
                    $_
                } else {
                    $_.psobject.Properties |
                        Where-Object { $_.Name -ne "ComputerName" } |
                        ForEach-Object {
                            $_.Value
                    }
                }
            }

        }

        if ($UpdateValue) {
            $IHateThisVariable | Export-Csv -NoTypeInformation $InputFile
        } else {
            $IHateThisVariable
        }
}

# Recreates the original CSV file
function Recreate-TestCsv {
    param (
        $InputFile
    )
@"
ComputerName,Value1,Value2,Value3,Value4,Value5
Mercury,5,8,4,5,6
Venus,13,5,15,11,10
Earth,4,4,3,3,3
Mars,15,14,13,12,11
Jupiter,17,20,2,4,16
Saturn,13,7,4,5,9
Uranus,16,17,18,19,20
Neptune,1,1,1,1,1
"@ |
    ConvertFrom-Csv |
    Export-Csv -NoTypeInformation -Path $InputFile
}

# $CsvPath = "C:\Users\jim.AD\SkyDrive\Documents\Powershell\theinternets\Challenge1.csv"
# Recreate-TestCsv $CsvPath
# Invoke-PowerCSV -ComputerName "Neptune" -UpdateValue 7 -InputFile $CsvPath
# Invoke-PowerCSV -ComputerName "Neptune" -InputFile $CsvPath