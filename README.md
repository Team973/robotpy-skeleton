# robotpy-skeleton
## Python (RobotPy) base code for FRC Team 973: Greybots

[![Build Status](https://travis-ci.com/Team973/2017-inseason.svg?token=PMQ4h4i9r3eRUJnsCJBt&branch=master)](https://travis-ci.com/Team973/2017-inseason)
[![FRC Year](https://img.shields.io/badge/frc-2017-brightgreen.svg)](https://www.firstinspires.com/robotics/frc/game-and-season)
[![Language Type](https://img.shields.io/badge/language-python-brightgreen.svg)](https://http://robotpy.readthedocs.io/)

## Automated Installation
Use the installation script for an easier install.

Regular install:

macOS & Debian Variant:
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/team973/robotpy-skeleton/install.rb)
```

Windows:
1.. Download [robotpy-install.bat](https://raw.githubusercontent.com/team973/robotpy-skeleton/robotpy-install.bat)
2. Double click downloaded file.

973 Install:

macOS & Debian Variant:
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/team973/robotpy-skeleton/973install.rb)
```

Windows:
1. Download [robotpy-973install.bat](https://raw.githubusercontent.com/team973/robotpy-skeleton/robotpy-973install.bat)
2. Double click downloaded file.

## Manual Installation
If you can't get the automated install to work.

### Dependencies
Requirements for RobotPy
- Python 3.4+

### Prepare the roboRIO
Setup the roboRio for RobotPy

macOS & Debian Variant:
```
pip3 install robotpy-installer
robotpy-installer download-robotpy
robotpy-installer install-robotpy
```

Windows:
```
py -3 -m pip install robotpy-installer
py -3 -m robotpy-installer download-robotpy
py -3 -m robotpy-installer install-robotpy
```

### Prepare Environment
Setup your computer for programming.

macOS & Debian Variant:
```
pip3 install pyfrc coverage
```

Windows:
```
py -3 -m pip install pyfrc coverage
```

## Usage
Use the skeleton.

macOS & Debian Variant:
```
cd robotpy-skeleton/src
python3 robot.py test
```

Windows:
```
cd robotpy-skeleton/src
py -3 robot.py test
```
