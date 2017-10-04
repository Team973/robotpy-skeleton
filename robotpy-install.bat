@echo off
set ARGV[0]=%1

if %ARGV[0]%=="973" (
  echo Using 973's 2017-offseason...
  set ROBOT_REPOSITORY=2017-offseason
  set REPO=https://github.com/team973/2017-offseason
) else (
  echo No argument supplied/argument not supported, defaulting...
  set ROBOT_REPOSITORY=robotpy-skeleton
  set REPO=https://github.com/team973/robotpy-skeleton
)

echo Creating install directory...
if not exist "C:\robotpy-install\" mkdir C:\robotpy-install
cd C:\robotpy-install

if not exist "%HOMEPATH%\AppData\Local\atom\atom.exe" (
  if not exist "AtomSetup-x64.exe" (
      echo Downloading Atom...
      powershell -Command "Invoke-WebRequest https://atom.io/download/windows_x64 -OutFile AtomSetup-x64.exe" || goto :error
  )
  echo Installing Atom...
  start /w AtomSetup-x64.exe
)

if not exist "atompackages" (
  echo Downloading Atom package list...
  powershell -Command "Invoke-WebRequest https://raw.githubusercontent.com/Team973/robotpy-skeleton/master/atompackages -OutFile atompackages.bat" || goto :error
)
echo Installing Atom Packages...
for /f %%a in (atompackages) do (
  apm install %%a || goto :error
)

if not exist "%HOMEPATH%\AppData\Local\Programs\Python\Python36-32\" (
  if not exist "python-3.6.2.exe" (
    echo Downloading Python 3.6.2...
    powershell -Command "Invoke-WebRequest https://www.python.org/ftp/python/3.6.2/python-3.6.2.exe -OutFile python-3.6.2.exe" || goto :error
  )
  echo Installing Python...
  start /w python-3.6.2.exe
)

echo Installing Python Modules...
py -3 -m pip install pyfrc coverage robotpy-ctre robotpy-installer || goto :error

if not exist "C:\Program/ Files\Git\" (
  if not exist "Git-2.14.1-64-bit.exe" (
    echo Downloading Git...
    powershell -Command "Invoke-WebRequest https://github.com/git-for-windows/git/releases/download/v2.14.1.windows.1/Git-2.14.1-64-bit.exe -OutFile Git-2.14.1-64-bit.exe" || goto :error
  )
  echo Installing Git...
  start /w Git-2.14.1-64-bit.exe
)

echo Creating GitHub folder...
if not exist "%HOMEPATH%\Documents\GitHub" mkdir %HOMEPATH%\Documents\GitHub
cd %HOMEPATH%\Documents\GitHub

if %ARGV[0]%=="973" (
  echo Cloning 2017-offseason...
  git clone https://github.com/team973/2017-offseason || goto :error
  echo Testing robot.py...
  py -3 2017-offseason\wood\src\robot.py test || goto :error
) else (
  echo Cloning robotpy-skeleton...
  git clone https://github.com/team973/robotpy-skeleton || goto :error
  echo Testing robot.py...
  py -3 robotpy-skeleton\src\robot.py test || goto :error
)

echo Success! We are done"

echo ONLY HIT ENTER IF YOU WANT TO SETUP ROBORIO! Otherwise, hit ^C
pause

echo Unplug ethernet if plugged in!"
pause

echo Downloading RobotPy for RoboRio...
py -3 -m robotpy-installer download-robotpy

echo Plug in ethernet now!"
pause

echo Installing RobotPy for RoboRio...
set /p ROBOT=Enter your robot's number:
py -3 -m robotpy-installer install-robotpy --robot %ROBOT%

echo Success! You may unplug ethernet now.

pause

:error
exit /b %errorlevel%
