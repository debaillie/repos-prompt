#!/usr/bin/env ruby
#TODO: add git check

#formatting
RED="\033[01;31m"
GREEN="\033[01;32m"
LIGHT_BLUE="\033[01;34m"
GREY="\033[0;37m"
NO_FORMAT="\033[00m"
YELLOW="\033[01;33m"
BLUE="\033[0;34m"

#handle arguments
if ARGV.size != 3
  print "\n"+YELLOW+"> "+NO_FORMAT
  exit -1
end

$ret_val = ARGV[0].to_i
$columns = ARGV[1].to_i
$username = `whoami`.chomp.sub(/^.*\\/,'')
$hostname = `hostname`.chomp.sub(/\.local$/,'')
$directory = ARGV[2].to_s.chomp
$homedir = `echo $HOME`.chomp

$remaining = $columns

def svn_path
  info = `svn info 2>&1`
  path = info.slice(/^URL:.*$/)
  root = info.slice(/^Repository Root:.*$/)
  if path and root
    root = root.split(' ')[2].strip
    root = root.sub(/[^\/]*\/?$/,'')

    path = path.split(' ')[1].lstrip
    path = path.sub(root,'')
    path = path.sub(/^[^\/]*\/\/[^\/]*\//,'')
  end
  path
end

def git_path
  path = `git branch 2>&1`.slice(/^\*.*$/)
  if path
    path = path.split(' ')[1].strip
  end
  path
end

$repos_path=false
def repos_path
  unless $repos_path
    $repos_path = svn_path || git_path || ''
  end
  $repos_path
end

def repos_info
  output = ""
  unless repos_path.empty?

    spaces = $remaining - repos_path.length - 2

    path = repos_path.to_s
    if spaces >= 0
      spaces.times do
        output += " "
      end
    elsif spaces == -1 
      path="~"+path[2..-1]
    else
      spaces -= 1
      path = "~"+path[(0-spaces)..-1]
    end
    path = '[' + path + ']'

    output += GREY+path+NO_FORMAT
  end
  output
end

def directory
  dir = $directory.sub(/^#{$homedir}/, '~')
  $remaining -= dir.length
  LIGHT_BLUE+dir+NO_FORMAT
end

def user_and_host
  $remaining -= $hostname.length
  if $username =~ /^root$/
    RED+$hostname+NO_FORMAT
  else
    $remaining -= $username.length + 1
    GREEN+$username+'@'+$hostname+NO_FORMAT
  end
end

def time
  time = 
    if $remaining > (repos_path.length + 14)
      Time.now.strftime(" %m/%d %H:%M") 
    else #guarantee time is always displayed
      Time.now.strftime(" %H:%M ") 
    end
  $remaining -= time.length
  BLUE+time+NO_FORMAT
end

def space
  $remaining -= 1
  " "
end

print "\n"
print directory
print space
print user_and_host
print time
print repos_info
print "\n"

exit $ret_val
