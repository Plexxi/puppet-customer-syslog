# == Class: customer-syslog
#
# Puppet module to manage customer syslog configuration
#
# === Parameters
#
# Document parameters here.
#
# [enabled]
#   Enable customer syslog support (Boolean)
#   **Required**
# [host]
#   Address of Syslog servers.
#   **Required if enabled**
# [port]
#   UDP port number (defaults to 514)
#   *Optional*
# [facility]
#   Syslog facility to forward (defaults to all)
#   *Optional*
#   Facilities supported:
#      ALL
#      KERN
#      USER
#      MAIL
#      DAEMON
#      AUTH
#      SYSLOG
#      LPR
#      NEWS
#      UUCP
#      CRON
#      SECURITY
#      FTP
#      NTP
#      LOGAUDIT
#      LOGALERT
#      CLOCK
#      LOCAL0
#      LOCAL1
#      LOCAL2
#      LOCAL3
#      LOCAL4
#      LOCAL5
#      LOCAL6
#      LOCAL7
# [severity]
#   Syslog severity level to forward (defaults to all)
#   *Optional*
#   Severity values supported:
#      ALL
#      EMERG
#      ALERT
#      CRIT
#      ERROR
#      WARNING
#      NOTICE
#      INFO
#      DEBUG
#
# === Examples
#
#  class { 'customer-syslog':
#    enabled => true,
#    entry_list => '[ { host => 192.168.1.1',
#                       port => 514,
#                       facility => 'all',
#                       severity => 'all'
#                      } ]
#  }
#
# === Authors
#
# Matthew Morgan <matt.morgan@plexxi.com>
#
# === Copyright
#
# Copyright 2017 Matthew Morgan, Plexxi, Inc
#
class customer-syslog(
  $enabled,
  $entry_list = [],
) {

      #  $host       = undef,
      #  $port       = 514,
      #  $facility   = 'all',
      #  $severity   = 'all',
      define validate_entries {
          $approved_facility = [
              'all',
              'kern',
              'user',
              'mail',
              'daemon',
              'auth',
              'syslog',
              'lpr',
              'news',
              'uucp',
              'cron',
              'security',
              'ftp',
              'ntp',
              'logaudit',
              'logalert',
              'clock',
              'local0',
              'local1',
              'local2',
              'local3',
              'local4',
              'local5',
              'local6',
              'local7'
              ]
          $approved_severity = [
              'all',
              'emerg',
              'alert',
              'crit',
              'error',
              'warning',
              'notice',
              'info',
              'debug'
              ]
          validate_hash($name)
          validate_re(downcase($name[facility]), $approved_facility)
          validate_re(downcase($name[severity]), $approved_severity)
          if has_key($name, port) {
              if is_integer($name[port]) {
                  if ($name[port] < 1) or ($name[port] > 65535) {
                      fail('port must be an integer from 1 to 65535')
                  }
              }
              else {
                  fail('port must be an integer')
              }
          }
          if !has_key($name, host) {
              fail('host must be provided for each list entry')
          }
      }

      validate_bool($enabled)
      validate_array($entry_list)
      validate_entries { $entry_list: }
      if $enabled { 
          file { '/etc/rsyslog.d/98customer.conf':
                  ensure  => file,
                  owner   => 0,
                  group   => 0,
                  mode    => '0644',
                  content => template('customer-syslog/98customer.conf.erb'),
           }
           exec { 'rsyslog_restart':
                   command => '/usr/sbin/service rsyslog restart',
           }
      }
      else {
          file { '/etc/rsyslog.d/98customer.conf':
                  ensure  => absent,
          }
          exec { 'rsyslog_restart':
                  command => '/usr/sbin/service rsyslog restart',
          }
      }
}
