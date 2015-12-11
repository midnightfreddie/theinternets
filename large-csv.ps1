[cmdletbinding()]
param (
    $InCsv = "C:\temp\allCountries.txt",
    $OutCsv = "C:\Temp\allCountries2.csv",
    $InSeparator = "`t"
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
        }
        # emit the current object/row, pass it down the pipeline
        $_
    }
    end {
        Write-Verbose "Ending working set: $((Get-Process -PID $pid).WorkingSet64)"

    }
}

Measure-Command {
    Import-Csv -Delimiter $InSeparator $InCsv |
        Track-Info |
        Export-Csv -NoTypeInformation $OutCsv
}

# For an 82MB CSV file
# Days              : 0
# Hours             : 0
# Minutes           : 4
# Seconds           : 44
# Milliseconds      : 498
# Ticks             : 2844989680
# TotalDays         : 0.00329281212962963
# TotalHours        : 0.0790274911111111
# TotalMinutes      : 4.74164946666667
# TotalSeconds      : 284.498968
# TotalMilliseconds : 284498.968

# Wait a few seconds to allow memory to free up
Start-Sleep -Seconds 20

Measure-Command {
    Get-Content $InCsv |
        Track-Info |
        Out-File -Encoding ascii $OutCsv
}

# For an 82MB CSV file
# Days              : 0
# Hours             : 0
# Minutes           : 4
# Seconds           : 59
# Milliseconds      : 452
# Ticks             : 2994525084
# TotalDays         : 0.00346588551388889
# TotalHours        : 0.0831812523333333
# TotalMinutes      : 4.99087514
# TotalSeconds      : 299.4525084
# TotalMilliseconds : 299452.5084