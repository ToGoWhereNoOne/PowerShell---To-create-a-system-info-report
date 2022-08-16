
<#

.AUTHOR to YOU (Smart bunch + amazing trekkies)
    -   To help you, I spent time and effort to create this script and save you and your team some headaches 
    -   To help me, please give this script a "star", "Follow me", improve this script or share the link in social media 


.LINK
    -   This link:
	    https://github.com/ToGoWhereNoOne/PowerShell
    

.USE
    -   To create a system info report to include hardware and software


.USE CASES
    -   Internal or external auditor asks for system details on the fly.
    -   Supervisor needs details on a machine to see if a specifc app is installed in it


.INSTRUCTIONS

    1)	Go to the start menu > start typing "PowerShell" > click on "Windows Powershell ISE" > click on "Run as administrator"
    2)  Go to the script repository > copy the script
    3)  Go back to the "Windows Powershell ISE" > paste copied script into the blank file
    4)  Replace What's in between *** with your data  

    -Video instructions: To be created when >50 people “star” this script


.NOTES
	Author: Q 
    1) If you are running the script at work or other sensitive environment, ensure your supervisor, the IT and/or Info Sec teams know about it for your own protection. These days there are tools that can detect PowerShell commands and can block you and trigger an alert and possibly an investigation.
    2) The script creator assumes no liability for the function, use or any consequences of this free script.
    3) This script was created in good faith to avoid doing tedious, redundant or time-consuming work.
    4) Get better than me:
    -   https://docs.microsoft.com/en-us/powershell/
    -   https://www.youtube.com/watch?v=at_MagcYK5M 
    -   https://www.youtube.com/watch?v=UVUd9_k9C6A
#> 

	

		# Global variables to start the build report 
		$userName4SysInfoReport = (Get-Item env:\username).Value 			
		$ReportName4SysInfoReport =  (Get-Item env:\Computername).Value

		# 
		If(!(test-path C:\Temp_byIT)){md C:\Temp_byIT}
		$path2theTempFolderbyIT = "C:\Temp_byIT"

		ConvertTo-Html  -Body "<H2> PC Name: $ReportName4SysInfoReport </H2>" > "$path2theTempFolderbyIT\$ReportName4SysInfoReport.html"  
		$Report = "Report generated on $(Get-Date -Format "dddd MM/dd/yyyy 'at' hh:mm tt") by $((Get-Item env:\username).Value)"
		$Report  >> "$path2theTempFolderbyIT\$ReportName4SysInfoReport.html"

		###Generates the sys build report:
		#  Hardware Information
		ConvertTo-Html -Body "<H2><b> <center> |||||||||||| Hardware Info |||||||||||| </center></b></H2>" >> "$path2theTempFolderbyIT\$ReportName4SysInfoReport.html"
								
		Get-WmiObject win32_DiskDrive -ComputerName .  | Select Model,MediaType,FirmwareRevision `
			 | ConvertTo-html -Body "<h3> Physical DISK Drives </h3>"  >>  "$path2theTempFolderbyIT\$ReportName4SysInfoReport.html"

		Get-WmiObject -Class Win32_LogicalDisk -Filter DriveType=3 -ComputerName . | Select DeviceID , @{Name=”Size(GB)”;Expression={“{0:N1}” -f($_.size/1gb)}}, @{Name=”Freespace(GB)”;Expression={“{0:N1}” -f($_.freespace/1gb)}} `
             | ConvertTo-html -Body "<h3> Logical DISK Drives </h3>" >>  "$path2theTempFolderbyIT\$ReportName4SysInfoReport.html"

		Get-WmiObject -Class Win32_Processor  | Select Name , Manufacturer , status `
			 | ConvertTo-html -Body "<h3> CPU Info </h3>"  >>  "$path2theTempFolderbyIT\$ReportName4SysInfoReport.html"

		Get-WmiObject -Class Win32_PhysicalMemory | Select -Property Tag , SerialNumber , PartNumber , Manufacturer , DeviceLocator , @{Name="Capacity(GB)";Expression={"{0:N1}" -f ($_.Capacity/1GB)}} `
			 | ConvertTo-html -Body "<h3> Memory Info </h3>"  >>  "$path2theTempFolderbyIT\$ReportName4SysInfoReport.html"
			
		Get-WmiObject Win32_NetworkAdapter -filter  "AdapterTypeID = '0' `
													 AND PhysicalAdapter = 'true' `
													 AND NOT Description LIKE '%wireless%' `
													 AND NOT Description LIKE '%WiFi%' `
													 AND NOT Description LIKE '%Bluetooth%'"  `
			 | Select Name,Manufacturer,Description ,AdapterType,MACAddress,NetConnectionID `
			 | ConvertTo-html -Body "<h3> Network Adapters </h3>" >>  "$path2theTempFolderbyIT\$ReportName4SysInfoReport.html"	
																				
		#  OS Information
		ConvertTo-Html -Body "<H2><b><center> |||||||||||| Software Info |||||||||||| </center></b></H2>" >> "$path2theTempFolderbyIT\$ReportName4SysInfoReport.html" 

		#  BIOS Information
		Get-WmiObject win32_bios -ComputerName . | select Manufacturer, @{Expression={$_.ConvertToDateTime($_.releasedate).ToShortDateString()};Label="Release Date:"} , SerialNumber `
			 | ConvertTo-html -Body "<h3> BIOS Information</h3>" >>  "$path2theTempFolderbyIT\$ReportName4SysInfoReport.html"

		get-WmiObject win32_operatingsystem -ComputerName .  | select Caption,@{Expression={$_.ConvertToDateTime($_.InstallDate).ToShortDateString()};Label="Install Date:"},OSArchitecture,CSDVersion `
			 | ConvertTo-html -Body "<h3> Operating System Information</h6>" >>  "$path2theTempFolderbyIT\$ReportName4SysInfoReport.html"

		#Get-WmiObject win32_DiskDrive -ComputerName .  -Filter "MediaType='Fixed hard disk media'" | foreach  {$_.Model}
		Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object  @{Expression={($_.DisplayName)};Label="App Name"}, @{Expression={($_.DisplayVersion)};Label="Version"}, @{Expression={($_.installDate.insert(4,"/").insert(7,"/"))};Label="Install Date"} , @{Expression={($_.Publisher)};Label="Vendor"} `
        | ConvertTo-html  -Head $buildReportFormating -Body "<h3> Apps Installed </h3>" >>  "$path2theTempFolderbyIT\$ReportName4SysInfoReport.html"					

        Start-Process "$path2theTempFolderbyIT\$ReportName4SysInfoReport.html"
