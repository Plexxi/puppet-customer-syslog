# == Class: customer_syslog
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
#  class { 'customer_syslog':
#    enabled => true,
#    entry_list => [ { host => "192.168.1.1",
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
# Copyright 2018 Matthew Morgan, Plexxi, Inc
#
class customer_syslog (
  Boolean $enabled,
  Array[Struct[{ host => String,
                 port => Optional[Integer],
                 facility => Pattern[/(?i:^all$)/,
                                     /(?i:^kern$)/,
                                      /(?i:^user$)/,
                                      /(?i:^mail$)/,
                                  /(?i:^daemon$)/,
                                  /(?i:^auth$)/,
                                  /(?i:^syslog$)/,
                                  /(?i:^lpr$)/,
                                  /(?i:^news$)/,
                                  /(?i:^uucp$)/,
                                  /(?i:^cron$)/,
                                  /(?i:^security$)/,
                                  /(?i:^ftp$)/,
                                  /(?i:^ntp$)/,
                                  /(?i:^logaudit$)/,
                                  /(?i:^logalert$)/,
                                  /(?i:^clock$)/,
                                  /(?i:^local0$)/,
                                  /(?i:^local1$)/,
                                  /(?i:^local2$)/,
                                  /(?i:^local3$)/,
                                  /(?i:^local4$)/,
                                  /(?i:^local5$)/,
                                  /(?i:^local6$)/,
                                  /(?i:^local7$)/],
             severity => Pattern[/(?i:^all$)/,
                                  /(?i:^emerg$)/,
                                  /(?i:^alert$)/,
                                  /(?i:^crit$)/,
                                  /(?i:^error$)/,
                                  /(?i:^warning$)/,
                                  /(?i:^notice$)/,
                                  /(?i:^info$)/,
                                  /(?i:^debug$')/]             
             }]] $entry_list = [],
) {

      #  $host       = undef,
      #  $port       = 514,
      #  $facility   = 'all',
      #  $severity   = 'all',
      define validate_entries (Hash $entry = {}, ) {
          if has_key($entry, port) {
              if is_integer($entry[port]) {
                  if ($entry[port] < 1) or ($entry[port] > 65535) {
                      fail('port must be an integer from 1 to 65535')
                  }
              }
              else {
                  fail('port must be an integer')
              }
          }
          if !has_key($entry, host) {
              fail('host must be provided for each list entry')
          }
      }

      $entry_list.each |$value| {
          customer_syslog::validate_entries { 'check_entry':
                                              entry => $value }
      }
      if $enabled { 
          file { '/etc/rsyslog.d/98customer.conf':
                  ensure  => file,
                  owner   => 0,
                  group   => 0,
                  mode    => '0644',
                  content => template('customer_syslog/98customer.conf.erb'),
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
