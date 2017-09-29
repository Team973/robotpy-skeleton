#!/usr/bin/ruby
ROBOT_REPOSITORY = File.join(Dir.home(), "/2017-offseason").freeze
OFFSEASON_REPO = "https://github.com/team973/2017-offseason".freeze

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

class Version
  include Comparable
  attr_reader :parts

  def initialize(str)
    @parts = str.split(".").map { |p| p.to_i }
  end

  def <=>(other)
    parts <=> self.class.new(other).parts
  end
end

# Look for GitHub
def gitMac
  @git ||= if ENV["GIT"] && File.executable?(ENV["GIT"])
    ENV["GIT"]
  elsif Kernel.system "/usr/bin/which -s git"
    "git"
  else
    exe = `xcrun -find git 2>/dev/null`.chomp
    exe if $? && $?.success? && !exe.empty? && File.executable?(exe)
  end

  return unless @git
  # Github only supports HTTPS fetches on 1.7.10 or later:
  # https://help.github.com/articles/https-cloning-errors
  `#{@git} --version` =~ /git version (\d\.\d+\.\d+)/
  return if $1.nil?
  return if Version.new($1) < "1.7.10"

  @git
end

def gitLinux
  @git ||= if ENV["GIT"] && File.executable?(ENV["GIT"])
    ENV["GIT"]
  elsif Kernel.system "/usr/bin/which -a git"
    "git"
  else
    exe = `xcrun -find git 2>/dev/null`.chomp
    exe if $? && $?.success? && !exe.empty? && File.executable?(exe)
  end

  return unless @git
  # Github only supports HTTPS fetches on 1.7.10 or later:
  # https://help.github.com/articles/https-cloning-errors
  `#{@git} --version` =~ /git version (\d\.\d+\.\d+)/
  return if $1.nil?
  return if Version.new($1) < "1.7.10"

  @git
end

def gitLinux
  @git ||= if ENV["GIT"] && File.executable?(ENV["GIT"])
    ENV["GIT"]
  elsif Kernel.system "/usr/bin/which -a git"
    "git"
  else
    exe = `xcrun -find git 2>/dev/null`.chomp
    exe if $? && $?.success? && !exe.empty? && File.executable?(exe)
  end

  return unless @git
  # Github only supports HTTPS fetches on 1.7.10 or later:
  # https://help.github.com/articles/https-cloning-errors
  `#{@git} --version` =~ /git version (\d\.\d+\.\d+)/
  return if $1.nil?
  return if Version.new($1) < "1.7.10"

  @git
end

def atomMac
  @atom ||= if ENV["atom"] && File.executable?(ENV["atom"])
    ENV["atom"]
  elsif Kernel.system "/usr/bin/which -s atom"
    "atom"
  else
    exe = `xcrun -find atom 2>/dev/null`.chomp
    exe if $? && $?.success? && !exe.empty? && File.executable?(exe)
  end

  @atom
end

def atomLinux
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

def cloneMac
  # we do it in four steps to avoid merge errors when reinstalling
  system gitMac, "init", "-q"

  # "git remote add" will fail if the remote is defined in the global config
  system gitMac, "config", "remote.origin.url", OFFSEASON_REPO
  system gitMac, "config", "remote.origin.fetch", "+refs/heads/*:refs/remotes/origin/*"

  # ensure we don't munge line endings on checkout
  system gitMac, "config", "core.autocrlf", "false"

  args = gitMac, "fetch", "origin", "master:refs/remotes/origin/master",
         "--tags", "--force"
  system(*args)

  system gitMac, "reset", "--hard", "origin/master"
end

def cloneLinux
  # we do it in four steps to avoid merge errors when reinstalling
  system gitLinux, "init", "-q"

  # "git remote add" will fail if the remote is defined in the global config
  system gitLinux, "config", "remote.origin.url", OFFSEASON_REPO
  system gitLinux, "config", "remote.origin.fetch", "+refs/heads/*:refs/remotes/origin/*"

  # ensure we don't munge line endings on checkout
  system gitLinux, "config", "core.autocrlf", "false"

  args = gitLinux, "fetch", "origin", "master:refs/remotes/origin/master",
         "--tags", "--force"
  system(*args)

  system gitLinux, "reset", "--hard", "origin/master"
end

def cloneRobot
  if OS.mac?
    cloneMac
  elsif OS.linux?
    cloneLinux
  end
end

# Invalidate sudo timestamp before exiting (if it wasn't active before).
Kernel.system "/usr/bin/sudo -n -v 2>/dev/null"
at_exit { Kernel.system "/usr/bin/sudo", "-k" } unless $?.success?

Dir.chdir(Dir.home())

wait_for_user

ohai "Creating install directory..."
if ! File.exist?(File.join(Dir.home(), "/robotpy-install"))
  Dir.mkdir(File.join(Dir.home(), "/robotpy-install"))
end
Dir.chdir(File.join(Dir.home(), "/robotpy-install"))

if OS.mac?
  ohai "Installing Homebrew..."
  system "/usr/bin/ruby -e '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)'"
  ohai "Installing Atom for macOS..."
  if File.exist?("atom-mac.zip")
    puts "Already Downloaded, remove file to redownload."
  else
    system "/usr/bin/curl -Lo atom-mac.zip https://atom.io/download/mac"
  end
  if ! atomMac
    system "/usr/bin/unzip -qq atom-mac.zip"
    sudo "/bin/cp", "-R", "Atom.app", "/Applications/"
      puts "Next step: Open Atom after done and go to Atom>Install Shell Commands"
  end
  system "/Applications/Atom.app/Contents/Resources/app/apm/node_modules/.bin/apm install '$(curl -fsSL https://raw.githubusercontent.com/team973/robotpy-skeleton/atompackages)'"
elsif OS.linux?
  ohai "Installing Atom for Debian..."
  if File.exist?("atom-amd64.deb")
    puts "Already downloaded, remove file to redownload."
  else
    system "/usr/bin/curl -Lo atom-amd64.deb https://atom.io/download/deb"
  end
  if ! atomLinux
    sudo "/usr/bin/dpkg", "-i", "atom-amd64.deb"
  end
  system "/usr/bin/apm install '$(curl -fsSL https://raw.githubusercontent.com/team973/robotpy-skeleton/atompackages)'"
end

ohai "Cloning 2017-offseason..."
if ! File.exist?(ROBOT_REPOSITORY)
  Dir.mkdir(ROBOT_REPOSITORY)
end
Dir.chdir(ROBOT_REPOSITORY) do
  if OS.mac?
    if gitMac
      cloneRobot
    end
  elsif OS.linux?
    if gitLinux
      cloneRobot
    end
  else
    if OS.mac?
      system "/usr/local/bin/brew install git"
      cloneRobot
    elsif OS.linux?
      sudo "/usr/bin/apt", "install", "-y", "git"
      cloneRobot
    end
  end
end

ohai "Installing Python..."
if OS.mac?
  system "brew install python3"
elsif OS.linux?
  sudo "/usr/bin/apt", "install", "-y", "python3", "python3-pip", "python3-dev"
end

ohai "Installing Python packages..."
if OS.mac?
  system "/usr/local/bin/pip3 install pyfrc coverage robotpy-installer"
elsif OS.linux?
  system "/usr/bin/pip3 install pyfrc coverage robotpy-installer"
end

ohai "Dependencies Installed"

ohai "Testing RobotPy..."
Dir.chdir(File.join(ROBOT_REPOSITORY, "/src/"))
if OS.mac?
  system "/usr/local/bin/python3 robot.py test"
elsif OS.linux?
  system "/usr/bin/python3 robot.py test"
end

ohai "Success! We are done"

ohai "ONLY HIT ENTER IF YOU WANT TO SETUP ROBORIO! Otherwise, hit ^C."
wait_for_user

system "/usr/bin/ruby -e '$(curl -fsSL https://raw.githubusercontent.com/team973/robotpy-skeleton/roborio_setup.rb)'"
