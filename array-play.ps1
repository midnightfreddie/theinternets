# Arrays vs. ArrayLists vs. Object Streams

# Inspired by https://www.reddit.com/r/PowerShell/comments/3we039/is_powershell_the_best_way_to_sort_this_large_csv/cxvkzi7
# Commenter mentioned slowness of building an array

$Sequence = 1..10000

$Array = @()
$ArrayList = New-Object System.Collections.ArrayList

$Value = "All work and no play makes Jack a dull boy."

"+= an array creates a new array each time, thus takes up increasing amounts of RAM and is slow"
Measure-Command {
    $Sequence | ForEach-Object { $Array += $Value }
}

"An ArrayList acts much like an array, but you can use the .Add() method to incrementally add elements"
Measure-Command {
    $Sequence | ForEach-Object { $ArrayList.Add($Value) } 
}

"You can also just emit values and capture it in a variable. Often you can treat these like arrays."
Measure-Command {
    $ObjectStream = $Sequence | ForEach-Object { $Value }
}