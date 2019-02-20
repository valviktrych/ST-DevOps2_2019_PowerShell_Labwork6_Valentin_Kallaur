#1.	Для каждого пункта написать и выполнить соответсвующий скрипт автоматизации администрирования:
#1.1. Вывести все IP адреса вашего компьютера (всех сетевых интерфейсов)

Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=True -ComputerName . | Select-Object -Property IPAddress

#1.2. Получить mac-адреса всех сетевых устройств вашего компьютера.

Get-CimInstance Win32_NetworkAdapterConfiguration | Select Description, MACAddress | ? {$_.MACAddress -ne $null}

Get-WmiObject Win32_NetworkAdapterConfiguration -Credential VM2\Administrator -ComputerName VM2 | Select Description, MACAddress | ? {$_.MACAddress -ne $null}

#1.3. На всех виртуальных компьютерах настроить (удалённо) получение адресов с DHСP.

$names = @("VM1", "VM2", "VM3")
$cred1 = Get-Credential VM1\Administrator
$cred2 = Get-Credential VM2\Administrator
$cred3 = Get-Credential VM3\Administrator
$creds = @("$cred1", "$cred2", "$cred3") 
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=true" -ComputerName $names -Credential $creds | ForEach-Object -Process {$_.InvokeMethod("EnableDHCP", $null)}

#1.4. Расшарить папку на компьютере

(Get-WmiObject -List -Credential VM2\Administrator -ComputerName VM2 | Where-Object -FilterScript {$_.Name -eq "Win32_Share"}).InvokeMethod("Create",("C:\Temp","TempShare",0,25,"test share"))

net share tempshare=c:\temp /users:25 /remark:"testshare of the temp folder" 

#1.5. Удалить шару из п.1.4

(Get-WmiObject -Class Win32_Share -Credential VM2\Administrator -ComputerName VM2 -Filter "Name='TempShare'").InvokeMethod("Delete",$null)

#1.6. Скрипт входными параметрами которого являются Маска подсети и два ip-адреса. Результат  – сообщение (ответ) в одной ли подсети эти адреса.


#2.	Работа с Hyper-V
#2.1. Получить список коммандлетов работы с Hyper-V (Module Hyper-V)

Get-Command -Module hyper-v

#2.2. Получить список виртуальных машин

Get-VM

#2.3. Получить состояние имеющихся виртуальных машин

Get-VM | where {$_.State -eq 'Running'}

Get-VM | where {$_.State -eq 'Off'}

#2.4. Выключить виртуальную машину

Get-VM | where {$_.State -eq 'Running'} | Stop-VM

#2.5. Создать новую виртуальную машину

New-VM -Name Testmachine -path C:\vm-machine -MemoryStartupBytes 512MB

#2.6. Создать динамический жесткий диск

New-VHD -Path c:\vm-Machine\Testmahcine\Testmachine.vhdx -SizeBytes 10GB -Dynamic

#Добавляем созданный виртуальный диск к ВМ
Add-VMHardDiskDrive -VMName TestMachine -path "C:\vm-machine\Testmachine\Testmachine.vhdx"

#2.7. Удалить созданную виртуальную машину
#Удаляем Виртуальный диск
Remove-VMHardDiskDrive -VMName Testmachine -ControllerType IDE -ControllerNumber 1 -ControllerLocation 0
#Удаляем ВМ 
Remove-VM -Name "Testmachine" -Force


