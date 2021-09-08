
$domain="domain"
$gpos = Get-GPO -All -Domain $domain|Select @{ n='GUID'; e = {'{' + $_.Id.ToString().ToUpper() + '}'}}|Select -ExpandProperty GUID
$polPath = "\\$domain\SYSVOL\$domain\Policies\"
$folders = Get-ChildItem $polPath -Exclude 'PolicyDefinitions'
$gpoArray = $gpos.GUID
       ForEach ($folder in $folders) {
            if (-not $gpos.contains($folder.Name)) {
                $orphaned += $folder|out-file c:\temp\orphans.txt -append
            }
        }
 