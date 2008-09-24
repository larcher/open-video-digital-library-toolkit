# Copyright 2006-2008 by Mike Bailey. All rights reserved.
unless Capistrano::Configuration.respond_to?(:instance)
  abort "deprec2 requires Capistrano 2"
end
require "#{File.dirname(__FILE__)}/recipes/deprec"
require "#{File.dirname(__FILE__)}/recipes/deprecated"
# require "#{File.dirname(__FILE__)}/recipes/canonical"
require "#{File.dirname(__FILE__)}/recipes/users"
require "#{File.dirname(__FILE__)}/recipes/ssh"
require "#{File.dirname(__FILE__)}/recipes/nginx"
require "#{File.dirname(__FILE__)}/recipes/apache"
require "#{File.dirname(__FILE__)}/recipes/php"
require "#{File.dirname(__FILE__)}/recipes/svn"
require "#{File.dirname(__FILE__)}/recipes/trac"
require "#{File.dirname(__FILE__)}/recipes/ruby"
require "#{File.dirname(__FILE__)}/recipes/rails"
require "#{File.dirname(__FILE__)}/recipes/mongrel"
require "#{File.dirname(__FILE__)}/recipes/mysql"
require "#{File.dirname(__FILE__)}/recipes/postfix"
require "#{File.dirname(__FILE__)}/recipes/memcache"
require "#{File.dirname(__FILE__)}/recipes/monit"
require "#{File.dirname(__FILE__)}/recipes/network"
require "#{File.dirname(__FILE__)}/recipes/aoe"
require "#{File.dirname(__FILE__)}/recipes/ntp"
require "#{File.dirname(__FILE__)}/recipes/nagios"
require "#{File.dirname(__FILE__)}/recipes/heartbeat"
require "#{File.dirname(__FILE__)}/recipes/xen"
require "#{File.dirname(__FILE__)}/recipes/ubuntu"
require "#{File.dirname(__FILE__)}/recipes/lvm"
require "#{File.dirname(__FILE__)}/recipes/vnstat"
require "#{File.dirname(__FILE__)}/recipes/sphinx"
require "#{File.dirname(__FILE__)}/recipes/logrotate"
require "#{File.dirname(__FILE__)}/recipes/utils"
require "#{File.dirname(__FILE__)}/recipes/git"
require "#{File.dirname(__FILE__)}/recipes/apt_mirror"
# require "#{File.dirname(__FILE__)}/recipes/pdns"
require "#{File.dirname(__FILE__)}/recipes/gitosis"
require "#{File.dirname(__FILE__)}/recipes/ar_sendmail"
