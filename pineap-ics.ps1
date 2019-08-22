#This PowerShell script is for configuring ICS (Internet Connection Sharing) for you WifipineappleAP. Since Windows doesn'the
#like to remember the sharing option and I don't want to click a lot.. I gathered some stuff and created this wifipinappleICS.ps

#Script gathered by nokje
#source: https://social.technet.microsoft.com/Forums/lync/en-US/88003b3b-0e5c-49a7-bb20-cdbbbb435d09/enabling-windows-ics-from-powershell
#source: https://www.howtogeek.com/112660/how-to-change-your-ip-address-using-powershell/
#source: https://www.virtualizationhowto.com/2016/09/change-default-gateway-powershell/

#Gathering interfaceGuid's
$gw_ind=(Get-NetRoute -DestinationPrefix 0.0.0.0/0 | select -expand ifIndex )
$gateway_int=(Get-NetAdapter -ifIndex $gw_ind | select -expand InterfaceGuid)
$pineap_int=(Get-NetAdapter -InterfaceDescription ASIX* | select -expand InterfaceGuid)
$pinap_ind=(Get-NetAdapter -InterfaceDescription ASIX* | select -expand ifIndex)

Write-Host " 
    Hi.. Since Window doesn't like to remember it's network sharing settings. I tried to atleast help you out a bit.
    We are going to share the available internet connection (based on you default gateway) with the PinaAP interface. 
    Afterwards the script will configure the nessasry IP on to your interface. If this is all is done, you can happly
    browse to http://172.16.42.1:1471.

    This script will define sharing and ad the required IP address to the PineAP network adapter.
   "
      Write-Host " `
        PS..
        Run me as Administartor!
        " -ForegroundColor Red
 
   Read-Host 'Press Enter to continue...' |

# Register the HNetCfg library (once)
regsvr32 /s hnetcfg.dll

# Create a NetSharingManager object
$m = New-Object -ComObject HNetCfg.HNetShare

# Find connection
$c1 = $m.EnumEveryConnection |? { $m.NetConnectionProps.Invoke($_).Guid -eq "$pineap_int" }
$c2 = $m.EnumEveryConnection |? { $m.NetConnectionProps.Invoke($_).Guid -eq "$gateway_int" }

# Get sharing configuration
$config1 = $m.INetSharingConfigurationForINetConnection.Invoke($c1)
$config2 = $m.INetSharingConfigurationForINetConnection.Invoke($c2)

# Enable sharing (0 - public, 1 - private)
$config1.EnableSharing(1)
$config2.EnableSharing(0)

# Disable sharing
#$config.DisableSharing()

Get-NetIPAddress -InterfaceIndex $pinap_ind | select -expand IPv4Address
New-NetIPAddress -InterfaceIndex $pinap_ind -IPAddress “172.16.42.42” -PrefixLength 24
Get-NetIPAddress -InterfaceIndex $pinap_ind | select -expand IPv4Address

Write-Host "Done, have a good one!"
