#!/usr/bin/ruby

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

# Beautiful printing
def ohai(*args)
  puts "#{Tty.blue}==>#{Tty.bold} #{args.shell_s}#{Tty.reset}"
end

# For warning the user
def warn(warning)
  puts "#{Tty.red}Warning#{Tty.reset}: #{warning.chomp}"
end

# For running system commands
def system(*args)
  abort "Failed during: #{args.shell_s}" unless Kernel.system(*args)
end

# For using sudo
def sudo(*args)
  args.unshift("-A") unless ENV["SUDO_ASKPASS"].nil?
  ohai "/usr/bin/sudo", *args
  system "/usr/bin/sudo", *args
end


def getc
  system "/bin/stty raw -echo"
  if STDIN.respond_to?(:getbyte)
    STDIN.getbyte
  else
    STDIN.getc
  end
ensure
  system "/bin/stty -raw echo"
end

# Requires user to hit enter
def wait_for_user
  puts
  puts "Press RETURN to continue or any other key to abort"
  c = getc
  # we test for \r and \n because some stuff does \r instead
  abort unless (c == 13) || (c == 10)
end

# For finding Atom
def git
  @git ||= if ENV["git"] && File.executable?(ENV["git"])
    ENV["git"]
  elsif Kernel.system "/usr/bin/which -a git"
    "git"
  else
    exe = `xcrun -find git 2>/dev/null`.chomp
    exe if $? && $?.success? && !exe.empty? && File.executable?(exe)
  end

  @git
end

# For finding Atom
def atom
  @atom ||= if ENV["atom"] && File.executable?(ENV["atom"])
    ENV["atom"]
  elsif Kernel.system "/usr/bin/which -a atom"
    "atom"
  else
    exe = `xcrun -find atom 2>/dev/null`.chomp
    exe if $? && $?.success? && !exe.empty? && File.executable?(exe)
  end

  @atom
end

# For finding Homebrew
def brew
  @brew ||= if ENV["brew"] && File.executable?(ENV["brew"])
    ENV["brew"]
  elsif Kernel.system "/usr/bin/which -a brew"
    "brew"
  else
    exe = `xcrun -find brew 2>/dev/null`.chomp
    exe if $? && $?.success? && !exe.empty? && File.executable?(exe)
  end

  @brew
end

# For finding python3
def python3
  @python3 ||= if ENV["python3"] && File.executable?(ENV["python3"])
    ENV["python3"]
  elsif Kernel.system "/usr/bin/which -a python3"
    "python3"
  else
    exe = `xcrun -find python3 2>/dev/null`.chomp
    exe if $? && $?.success? && !exe.empty? && File.executable?(exe)
  end

  @python3
end

# For finding pip3
def pip3
  @pip3 ||= if ENV["pip3"] && File.executable?(ENV["pip3"])
    ENV["pip3"]
  elsif Kernel.system "/usr/bin/which -a pip3"
    "pip3"
  else
    exe = `xcrun -find pip3 2>/dev/null`.chomp
    exe if $? && $?.success? && !exe.empty? && File.executable?(exe)
  end

  @pip3
end

def cloneRobot
  system git, "init", "-q"
  system git, "config", "remote.origin.url", REPO
  system git, "config", "remote.origin.fetch", "+refs/heads/*:refs/remotes/origin/*"
  system git, "config", "core.autocrlf", "false"
  args = git, "fetch", "origin", "master:refs/remotes/origin/master",
         "--tags", "--force"
  system(*args)
  system git, "reset", "--hard", "origin/master"
end

# Invalidate sudo timestamp before exiting (if it wasn't active before).
Kernel.system "/usr/bin/sudo -n -v 2>/dev/null"
at_exit { Kernel.system "/usr/bin/sudo", "-k" } unless $?.success?

Dir.chdir(Dir.home())

if ARGV[0] == "973"
  puts "Using 973's 2017-offseason..."
  ROBOT_REPOSITORY = File.join(Dir.home(), "/Documents/GitHub/2017-offseason").freeze
  REPO = "https://github.com/team973/2017-offseason".freeze
else
  warn "No argument supplied/argument not supported, defaulting..."
  ROBOT_REPOSITORY = File.join(Dir.home(), "/Documents/GitHub/robotpy-skeleton").freeze
  REPO = "https://github.com/team973/robotpy-skeleton".freeze
end

if ! ARGV[0] == "travis"
  wait_for_user
end

ohai "Creating install directory..."
if ! File.exist?(File.join(Dir.home(), "/robotpy-install"))
  Dir.mkdir(File.join(Dir.home(), "/robotpy-install"))
end
Dir.chdir(File.join(Dir.home(), "/robotpy-install"))

if OS.mac?
  if ! brew
    ohai "Installing Homebrew..."
    system '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
  end
  if ! atom
    ohai "Installing Atom for macOS..."
    if File.exist?("atom-mac.zip")
      puts "Already Downloaded, remove file to redownload."
    else
      system "/usr/bin/curl -Lo atom-mac.zip https://atom.io/download/mac"
    end
    system "/usr/bin/unzip -qq atom-mac.zip"
    sudo "/bin/cp", "-R", "Atom.app", "/Applications/"
      puts "Next step: Open Atom after done and go to Atom>Install Shell Commands"
  end
  system "/Applications/Atom.app/Contents/Resources/app/apm/node_modules/.bin/apm install $(curl -fsSL https://raw.githubusercontent.com/team973/robotpy-skeleton/master/atompackages)"
elsif OS.linux?
  if ! atom
    ohai "Installing Atom for Debian..."
    if File.exist?("atom-amd64.deb")
      puts "Already downloaded, remove file to redownload."
    else
      system "/usr/bin/curl -Lo atom-amd64.deb https://atom.io/download/deb"
    end
    begin
      sudo "/usr/bin/dpkg", "-i", "atom-amd64.deb"
    rescue Exception # Shouldn't do this, but too lazy to find actual exception
      sudo "/usr/bin/apt", "-f", "install"
    end
  end
  system "/usr/bin/apm install $(curl -fsSL https://raw.githubusercontent.com/team973/robotpy-skeleton/master/atompackages)"
end

ohai "Cloning selected repository..."
if ! ARGV[0] = "travis"
  if ! File.exist?(File.join(Dir.home(), "/Documents/GitHub"))
    Dir.mkdir(File.join(Dir.home(), "/Documents/GitHub"))
    Dir.chdir(File.join(Dir.home(), "/Documents/GitHub"))
  end
  if ! File.exist?(ROBOT_REPOSITORY)
    Dir.mkdir(ROBOT_REPOSITORY)
  end
  Dir.chdir(ROBOT_REPOSITORY) do
    if git
      cloneRobot
    else
      ohai "Must install git first..."
      if OS.mac?
        system brew, "install", "git"
        cloneRobot
      elsif OS.linux?
        sudo "/usr/bin/apt", "install", "-y", "git"
        cloneRobot
      end
    end
  end
end

if ! python3
  ohai "Installing Python3..."
  if OS.mac?
    if ARGV[0] = "travis"
      system "HOMEBREW_NO_AUTO_UPDATE=1 brew install python3"
    else
      system brew, "install", "python3"
    end
  elsif OS.linux?
    sudo "/usr/bin/apt", "install", "-y", "python3", "python3-dev"
  end
end

if ! pip3
  ohai "Installing pip3..."
  if OS.mac?
    system brew, "install", "python3"
  elsif OS.linux?
    sudo "/usr/bin/apt", "install", "-y", "python3-pip"
  end
end

ohai "Installing Python packages...."
system pip3, "install", "pyfrc", "coverage", "robotpy-installer"

ohai "Dependencies Installed"

ohai "Testing RobotPy..."
if ARGV[0] = "973"
  Dir.chdir(File.join(ROBOT_REPOSITORY, "/wood/src/"))
else
  Dir.chdir(File.join(ROBOT_REPOSITORY, "/src/"))
end
system python3, "robot.py", "test"

ohai "Success! We are done"

ohai "ONLY HIT ENTER IF YOU WANT TO SETUP ROBORIO! Otherwise, hit ^C."
if ! ARGV[0] == "travis"
  wait_for_user

  system '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/team973/robotpy-skeleton/master/roborio_setup.rb)"'
end
