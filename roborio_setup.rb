#!/usr/bin/ruby
puts "Enter your robot's number: "
INPUT = gets
TEAM_NUMBER = INPUT.chomp
ROBOT_LOCATION = File.join("roborio-", TEAM_NUMBER, "-frc.local")

# Detecting OS
module OS
  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
   (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end
end

# Text output formatting
module Tty
  module_function

  def blue
    bold 34
  end

  def red
    bold 31
  end

  def reset
    escape 0
  end

  def bold(n = 39)
    escape "1;#{n}"
  end

  def underline
    escape "4;39"
  end

  def escape(n)
    "\033[#{n}m" if STDOUT.tty?
  end
end

class Array
  def shell_s
    cp = dup
    first = cp.shift
    cp.map { |arg| arg.gsub " ", "\\ " }.unshift(first).join(" ")
  end
end

def ohai(*args)
  puts "#{Tty.blue}==>#{Tty.bold} #{args.shell_s}#{Tty.reset}"
end

def warn(warning)
  puts "#{Tty.red}Warning#{Tty.reset}: #{warning.chomp}"
end

def system(*args)
  abort "Failed during: #{args.shell_s}" unless Kernel.system(*args)
end

def sudo(*args)
  args.unshift("-A") unless ENV["SUDO_ASKPASS"].nil?
  ohai "/usr/bin/sudo", *args
  system "/usr/bin/sudo", *args
end

if OS.mac?
  def getc # NOTE only tested on OS X
    system "/bin/stty raw -echo"
    if STDIN.respond_to?(:getbyte)
      STDIN.getbyte
    else
      STDIN.getc
    end
  ensure
    system "/bin/stty -raw echo"
  end
end

def wait_for_user
  puts
  puts "Press RETURN to continue or any other key to abort"
  c = getc
  # we test for \r and \n because some stuff does \r instead
  abort unless (c == 13) || (c == 10)
end

# Invalidate sudo timestamp before exiting (if it wasn't active before).
Kernel.system "/usr/bin/sudo -n -v 2>/dev/null"
at_exit { Kernel.system "/usr/bin/sudo", "-k" } unless $?.success?

ohai "Unplug ethernet if plugged in!"
wait_for_user

if OS.mac?
  ohai "Grabbing dependencies..."
  system "/usr/local/bin/pip3 install robotpy-installer"

  ohai "Downloading RobotPy for RoboRio..."
  system "/usr/local/bin/robotpy-installer download-robotpy"
  ohai "Downloading cscore, ctre..."
  system "/usr/local/bin/robotpy-installer download-opkg python36-robotpy-cscore python36-robotpy-ctre"
  puts "Plug in ethernet now!"
  wait_for_user

  ohai "Installing RobotPy for RoboRio..."
  system File.join("/usr/local/bin/robotpy-installer install-robotpy --robot ", ROBOT_LOCATION)
  ohai "Installing cscore, ctre..."
  system File.join("/usr/local/bin/robotpy-installer install-opkg --robot ", ROBOT_LOCATION, "python36-robotpy-cscore python36-robotpy-ctre")
  ohai "Success! You may unplug ethernet now."
elsif OS.linux?
  ohai "Grabbing dependencies..."
  system "/usr/bin/pip3 install robotpy-installer"

  ohai "Downloading RobotPy for RoboRio..."
  system "/usr/bin/robotpy-installer download-robotpy"
  ohai "Downloading cscore, ctre..."
  system "/usr/bin/robotpy-installer download-opkg python36-robotpy-cscore python36-robotpy-ctre"
  puts "Plug in ethernet now!"
  wait_for_user

  ohai "Installing RobotPy for RoboRio..."
  system File.join("/usr/bin/robotpy-installer install-robotpy --robot ", ROBOT_LOCATION)
  ohai "Installing cscore, ctre..."
  system File.join("/usr/bin/robotpy-installer install-opkg --robot ", ROBOT_LOCATION, "python36-robotpy-cscore python36-robotpy-ctre")
  ohai "Success! You may unplug ethernet now."
end
