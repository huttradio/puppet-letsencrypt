# Class: letsencrypt::server::apache
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
class letsencrypt::server::apache
(
  $ensure = 'present',

  $apache_vhost      = $::letsencrypt::params::apache_vhost,
  $apache_vhost_ip   = $::letsencrypt::params::apache_vhost_ip,
  $apache_vhost_port = $::letsencrypt::params::apache_vhost_port,

  $letsencrypt_dir = $::letsencrypt::params::letsencrypt_dir,
) include letsencrypt::params
{
  validate_re($ensure, ['^present$', '^latest$', '^absent$'], 'ensure can only be one of present, latest or absent')

  if ($ensure == 'present' or $ensure == 'latest')
  {
    class
    { '::apache':
      default_vhost => false,
    }

    ::apache::vhost
    { $apache_vhost:
      ip            => $apache_vhost_ip,
      port          => $apache_vhost_port,
      docroot       => $letsencrypt_dir,
      docroot_owner => $letsencrypt_dir_owner,
      docroot_group => $letsencrypt_dir_group,
      docroot_mode  => $letsencrypt_dir_mode,
    }
  }
}
