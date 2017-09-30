@echo off

echo Creating install directory
if not exist "C:\robotpy-install\" mkdir C:\robotpy-install
cd C:\robotpy-install

echo Downloading Atom
if not exist "AtomSetup-x64.exe" powershell -Command "Invoke-WebRequest https://atom.io/download/windows_x64 -OutFile AtomSetup-x64.exe" || goto :error
echo Downloading Python 3.6.2
if not exist "python-3.6.2.exe" powershell -Command "Invoke-WebRequest https://www.python.org/ftp/python/3.6.2/python-3.6.2.exe -OutFile python-3.6.2.exe" || goto :error
echo Downloading Git
if not exist "Git-2.14.1-64-bit.exe" powershell -Command "Invoke-WebRequest https://github.com/git-for-windows/git/releases/download/v2.14.1.windows.1/Git-2.14.1-64-bit.exe -OutFile Git-2.14.1-64-bit.exe" || goto :error
echo Downloading Atom Package List
if not exist "atompackages" powershell -Command "Invoke-WebRequest https://raw.githubusercontent.com/Team973/robotpy-skeleton/master/atompackages -OutFile atompackages.bat" || goto :error

echo Installing Atom
if not exist "%HOMEPATH%\AppData\Local\atom\atom.exe" start /w AtomSetup-x64.exe
echo Installing Atom Packages
for /f %%a in (atompackages) do (
apm install %%a || goto :error
)
echo Installing Python
start /w python-3.6.2.exe
echo Installing Python Modules
py -3 -m pip install pyfrc coverage robotpy-ctre robotpy-installer || goto :error
echo Installing Git
start /w Git-2.14.1-64-bit.exe

echo Creating GitHub folder
if not exist "%HOMEPATH%\Documents\GitHub" mkdir %HOMEPATH%\Documents\GitHub
cd %HOMEPATH%\Documents\GitHub
echo Cloning 2017-offseason
git clone https://github.com/team973/2017-offseason || goto :error
echo Testing robot.py
py -3 2017-offseason\src\robot.py test || goto :error
echo Opening in Atom
atom 2017-offseason\src\robot.py

echo To setup roborio, please use a unix system.
echo Done

pause

:error
exit /b %errorlevel%
