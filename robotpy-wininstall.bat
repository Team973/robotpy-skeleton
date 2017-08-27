@echo off

echo Creating install directory
if not exist "C:\robotpy-install\" mkdir C:\robotpy-install
cd C:\robotpy-install

echo Downloading Atom
if not exist "AtomSetup-x64.exe" powershell -Command "Invoke-WebRequest https://atom.io/download/windows_x64 -OutFile AtomSetup-x64.exe"
echo Downloading Python 3.6.2
if not exist "python-3.6.2.exe" powershell -Command "Invoke-WebRequest https://www.python.org/ftp/python/3.6.2/python-3.6.2.exe -OutFile python-3.6.2.exe"
echo Downloading Git
if not exist "Git-2.14.1-64-bit.exe" powershell -Command "Invoke-WebRequest https://github.com/git-for-windows/git/releases/download/v2.14.1.windows.1/Git-2.14.1-64-bit.exe -OutFile Git-2.14.1-64-bit.exe"

echo Installing Atom
start /w AtomSetup-x64.exe
echo Installing Atom Packages
apm install build build-make linter travis-ci-status busy busy-signal intentions linter-ui-default
echo Installing Python
start /w python-3.6.2.exe
echo Installing Python Modules
py -3 -m pip install pyfrc coverage pynetworktables robotpy-ctre
echo Installing Git
start /w Git-2.14.1-64-bit.exe

echo Creating GitHub folder
if not exist "%HOMEPATH%\Documents\GitHub" mkdir %HOMEPATH%\Documents\GitHub
cd %HOMEPATH\Documents\GitHub
echo Cloning robotpy-testing
git clone https://github.com/team973/robotpy-testing
echo Opening in Atom
atom robotpy-testing\src\robot.py

echo Done
