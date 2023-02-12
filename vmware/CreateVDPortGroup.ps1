$VDPortGroupCsv = Import-Csv .\DistributedSwitch.csv

Disconnect-VIServer -confirm:$false

$Prefix = "SimpleLab_"
$count = 1
$vc = "vc01.simplelab.int"

Connect-VIServer -Server $vc


Foreach ($VDPortGroup in $VDPortGroupCsv) {

   $PortGroupName = "$Prefix" + "$($VDPortGroup.Site)_" + "Vlan" + $("{0:d4}" -f $VDPortGroup.VlanId)
   
  "Loopcount $count start"
  "Createing $PortGroupName"

  if ( -not $(Get-VDPortgroup $PortGroupName -ErrorAction SilentlyContinue) ) {

    "$PortGroupName not Found"
    New-VDPortgroup -Name "$PortGroupName" -NumPorts 8 -VLanId "$($VDPortGroup.VlanId)" -VDSwitch "$($VDPortGroup.VDSwitch)"

  }
  else {
    "$PortGroupName Found"
  }

  "Finished handling $PortGroupName"
  "Loopcount $count end"
  ""

  $count++
  sleep 1

}
