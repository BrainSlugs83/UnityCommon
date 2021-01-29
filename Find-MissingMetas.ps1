cls
cd $PSScriptRoot

$guids = @{};

(gci -recu) | % {

    $file = $_.FullName;

    if (-not ($file.EndsWith("\.gitignore")))
    {
        $other = $file;

        if ($file.EndsWith(".meta"))
        {
            $other = $other.Substring(0, $other.Length - 5);

            $guid = cat $file | ? { $_ -imatch "^guid\:" }
            $guid = $guid.Substring(5).Trim();

            if (-not $guids.ContainsKey($guid))
            {
                $guids[$guid] = @($file);
            }
            else
            {
                $guids[$guid] += $file;
            }
        }
        else
        {
            $other += ".meta";
        }

        if (-not (Test-Path $other))
        {
            ("'" + $file + "' is missing the relevant '" + $other + "' file.");
        }
    }
}

$guids.Keys | % {

    if ($guids[$_].Count -gt 1)
    {
        Write-Warning ("'" + $_ + "' is used for multiple meta files:");
        $guids[$_];
    }
}