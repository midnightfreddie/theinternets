# Adapted from http://kunaludapi.blogspot.com/2015/12/format-table-color-style-odd-even-rows.html

filter Format-OddEven {
    begin {
        $Number = 0
        $ConsoleBack = [System.Console]::BackgroundColor
        $ConsoleFore = [System.Console]::ForegroundColor
        $RowColors = @(
            @{
                Back = "DarkGray"
                Fore = "Black"
            },
            @{
                Back = $ConsoleBack
                Fore = $ConsoleFore
            }
        )
    }
    process {
        $Number += 1
        $Index = [Math]::Floor($Number / 3) % 2
        [System.Console]::BackgroundColor = $RowColors[$Index].Back
        [System.Console]::ForegroundColor = $RowColors[$Index].Fore
        $_
    }
    end {
        [System.Console]::BackgroundColor = $ConsoleBack
        [System.Console]::ForegroundColor = $ConsoleFore
    }
<#
.Synopsis
Format table output row odd even colors.
.Example
Get-Service | Format-OddEven
.Notes
    NAME:  Format-OddEven
    AUTHOR: Kunal Udapi
    LASTEDIT: 10 Decemeber 2015
    KEYWORDS: Format Table color
.Link
Check Online version: Http://kunaludapi.blogspot.com
#>
} #function Format-OddEven