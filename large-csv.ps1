﻿[cmdletbinding()]
param (
    $InCsv = "C:\temp\allCountries.txt",
    $OutCsv = "C:\Temp\allCountries2.csv",
    $InSeparator = "`t",
    $Header = (1..19 | ForEach-Object { [char](64 + $_) }) -join ","
)

filter Track-Info {
    begin {
        $MaxWorkingSet = 0
        $RowCount = 0
        Write-Verbose "Starting working set: $((Get-Process -PID $pid).WorkingSet64)"
    }
    process {
        # Increment row counter
        $RowCount += 1
        # Every so often, check RAM use and write-verbose update
        if ($RowCount % 100000 -eq 0) {
            $WorkingSet = (Get-Process -PID $pid).WorkingSet64
            if ($WorkingSet -gt $MaxWorkingSet) {
                $MaxWorkingSet = $WorkingSet
            }
            Write-Verbose "Row $RowCount, Working set $WorkingSet, Max $MaxWorkingSet"
            [System.GC]::Collect()
        }
        # emit the current object/row, pass it down the pipeline
        $_
    }
    end {
        Write-Verbose "Rows: $RowCount, ending working set: $((Get-Process -PID $pid).WorkingSet64)"

    }
}


Measure-Command {
    Import-Csv -Delimiter $InSeparator $InCsv -Header $Header |
        Track-Info |
        Export-Csv -NoTypeInformation $OutCsv
}

# Measure-Command {
#     Get-Content $InCsv |
#         Track-Info |
#         Out-File -Encoding ascii $OutCsv 
# }

