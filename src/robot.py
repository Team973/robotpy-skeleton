#!/usr/bin/env python3

# Import required libraires
import magicbot
import wpilib


class MyRobot(magicbot.MagicRobot):
    """Create a robot"""

    # Initialize robot
    def createObjects(self):
        """Create basic components (motor controllers, joysticks, etc.)."""
        pass

    def autonomous(self):
        """Prepare for autonomous mode"""
        pass

    def teleopInit(self):
        """Begin Teleop"""
        pass

    def teleopPeriodic(self):
        """Do periodically while robot is in teleoperated mode."""
        pass

if __name__ == '__main__':
    wpilib.run(MyRobot)
