# Define: php::mod
#
# This define configures php mods-available to all SAPI using php5{en,dis}mod
#
# == Parameters
# 
# [*disable*]
#   Set to 'true' to disable the php mod-availables to all SAPI using php5{dis}mod
#   Default: false, i.e, Set the php mod-availables to all SAPI using php5{en}mod.
#
# [*service_autorestart*]
#   whatever we want a module installation notify a service to restart.
#
# == Usage
# 
# [name] is filename without .ini extension from /etc/php5/mods-available/<name>.ini
# 
# php::mod { "<name>": }
# 
# == Example
# 
# This will configure php5-mcrypt module to all SAPI
# 
# php::mod { "mcrypt": }
# 
# $mods = ["mcrypt", "mongo"]
# php::mod { "$mods": }
# 
# This will unconfigure php5-xdebug module to all SAPI
# 
# php::mod { "xdebug":
#   disable => true,
# }
# 
# Note that you may include or declare the php class when using
# the php::module define
#
define php::mod (
  $disable              = false,
  $service_autorestart  = '',
  $path                 = '/usr/bin:/bin:/usr/sbin:/sbin',
  $package              = $php::package
  ) {

  include php

  $real_service_autorestart = $service_autorestart ? {
    true    => "Service[${php::service}]",
    false   => undef,
    ''      => $php::service_autorestart ? {
      true    => "Service[${php::service}]",
      false   => undef,
    }
  }

  if $::operatingsystem == 'Debian'
    or $::operatingsystem == 'Ubuntu'
    or $::operatingsystem == 'Mint' {
      case $::ensure {
        'present': {

          exec { "/usr/sbin/php5enmod ${name}":
            unless  => "/usr/sbin/php5query -s apache2 -m ${name} | /bin/grep -qi enabled",
            path    => $path,
            notify  => $real_service_autorestart,
            require => Package[$package],
          }
                                                                                                                                                      }
        'absent': {
          exec { "/usr/sbin/php5dismod ${name}":
            onlyif  => "/usr/sbin/php5query -s apache2 -m ${name} | /bin/grep -qi enabled",
            path    => $path,
            notify  => $real_service_autorestart,
            require => Package[$package],
          }
        }
        default: { }
      }
    }
}
