# Steps to install WSL2 and Docker

## Description
These are the steps to install Docker and WSL2 on **Windows 10**.  

1-	Uninstall Docker.

2-	Delete all old Docker folders: ( Without deleting all existing files, you’ll get a timeout error, and Docker won’t start)   
- *C:\Users\useName\AppData\Local\Docker*   
- *C:\Users\useName\AppData\Roaming\Docker*   
- *C:\Users\useName\AppData\Roaming\Docker Desktop*

3-	Restart the computer.

4-	Run this command in power shell **(run as administrator)** to enable Windows Subsystem for Linux  
<code>*dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart*</code>

5-	Restart the computer.

6-	Enable the Virtual Machine feature by running this command **(run as administrator)**  
<code>*dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart*</code>

7-	Restart the computer.

8-	Update WSL 2 [here](https://docs.microsoft.com/en-us/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package).

9-	Run this command in power shell to set WSL2 as default version   
<code>*wsl --set-default-version 2*</code>

10-	Install Docker, and check the option for WSL2.

11-	Check if WSL is working  
In cmd type :<code> wsl -l -v</code>
- You should get **Version 2**

12-	If Docker didn’t start, keep trying to restart Docker, or even restart the computer until it successfully loads. You can also try *‘Reset to Factory Defaults’* in Docker Dashboard. 

13-	 To limit the CPU usage

- Create a file titled *(.wslconfig)* and save it at *C:/Users/<insert_your_name>/
- In the file, adjust to the required RAM  
<code>
[wsl2]   
memory=45GB # Limits VM memory in WSL 2 up to 45 GB    
processors=9 # Makes the WSL 2 VM use 9 virtual processors
</code>

##References
[StackOverFlow](https://stackoverflow.com/questions/68706512/how-to-create-a-wslconfig-file)  


