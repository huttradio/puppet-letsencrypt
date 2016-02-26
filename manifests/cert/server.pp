# Define: letsencrypt::cert
# ===========================
#
# Full description of class letsencrypt here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'letsencrypt':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Callum Dickinson <callum@huttradio.co.nz>
#
# Copyright
# ---------
#
# Copyright 2016 Hutt Community Radio and Audio Archives Charitable Trust.
#
define letsencrypt::cert::server
(
  $cron_manage  = true,
  $cron_command = undef,
  $cron_user    = undef,

  $ensure = 'present',
  $servername = $name,
)
{
  validate_re($ensure, ['^present$', '^absent$'], 'ensure can only be one of present or absent')

  if ($cron_manage)
  {
    $cron_hour    = fqdn_rand(24, $servername)
    $cron_minute  = fqdn_rand(60, $servername)

    validate_bool($cron_manage)
    validate_string($cron_command, $cron_user)
    validate_integer($cron_hour, $cron_minute)

    cron
    { "::letsencrypt::cert::cron::${servername}":
      command => $cron_command,
      user    => $cron_user,
      hour    => $cron_hour,
      minute  => $cron_minute,
    }
  }
}
