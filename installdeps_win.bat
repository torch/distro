rem This is very imperfect, since it assumes a lot of stuff is done by hand
rem But its a start
rem based heavily on hiili's instructions at https://github.com/torch/torch7/wiki/Windows#using-visual-studio

rem assumptions:
rem - ec2 windows 2012 r2 default box (eg ami-281ad849, or equivalent, in ec2, click 'Launch' and select
rem   'Microsoft Windows Server 2012 R2 Base', from 'Quick Start')
rem - powershell available (it is, by default, in above image)
rem
rem Target build:
rem - windows 64 bit
rem - cpu architecture etc on a g2.2xlarge ec2 box
rem
rem Note that this script isnt really standalone currently.  You kind of have to copy and paste a few lines at a
rem time into the terminal really

"C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
set "PATH=%PATH%;C:\Program Files\CMake\bin"

powershell Set-ExecutionPolicy unrestricted

mkdir C:\Downloads
set DOWNLOADS=C:\Downloads

rem download stuff
cd /d "%DOWNLOADS%"

powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('http://7-zip.org/a/7z920-x64.msi', '7x920-x64.msi')
msiexec /passive /i 7x920-x64.msi
rem poor man's sleep :-P
ping -n 10 127.0.0.1

powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('https://cmake.org/files/v3.6/cmake-3.6.2-win64-x64.msi', 'cmake-3.6.2-win64-x64.msi')
msiexec /passive /i cmake-3.6.2-win64-x64.msi
rem poor man's sleep :-P
ping -n 10 127.0.0.1

powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('https://github.com/git-for-windows/git/releases/download/v2.9.2.windows.1/Git-2.9.2-64-bit.exe', 'Git-2.9.2-64-bit.exe')
Git-2.9.2-64-bit.exe /silent
ping -n 30 127.0.0.1

rem install firefox, because it makes downloading visual studio express easier
powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('https://download.mozilla.org/?product=firefox-48.0.2-SSL"&"os=win"&"lang=en-US', 'firefox-48.0.2.exe')
firefox-48.0.2 /s
ping -n 10 127.0.0.1

"c:\Program Files (x86)\Mozilla Firefox\firefox.exe" "https://www.visualstudio.com/products/visual-studio-express-vs"
rem this will bring up the downloa dpage.  you still need to click through it, but it saves all those ie security dialogs...
rem download the vs2015 community edition, and then open it, run it, install it
