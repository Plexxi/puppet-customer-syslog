# == Class: customer-syslog
#
# Puppet module to manage TACACS+ PAM and NSS configuration.
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
#    host => '192.168.1.1',
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
  $host       = '0.0.0.0',
  $port       = 514,
  $facility   = 'all',
  $severity   = 'all',
) {
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

       validate_re(downcase($facility), $approved_facility)
       validate_re(downcase($severity), $approved_severity)
       
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
