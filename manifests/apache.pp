# Class: letsencrypt::apache
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
class letsencrypt::apache
(
  $ensure = 'present',

  $class_manage = true,
  $vhost_manage = true,

  $directories_manage = true,

  $vhost      = $::letsencrypt::params::vhost,
  $vhost_port = $::letsencrypt::params::vhost_port,

  $letsencrypt_dir_base  = $::letsencrypt::params::letsencrypt_dir_base,
  $letsencrypt_dir_owner = $::letsencrypt::params::letsencrypt_dir_owner,
  $letsencrypt_dir_group = $::letsencrypt::params::letsencrypt_dir_group,
  $letsencrypt_dir_mode  = $::letsencrypt::params::letsencrypt_dir_mode,
) inherits letsencrypt::params
{
  validate_re($ensure, ['^present$', '^latest$', '^absent$'], 'ensure can only be one of present, latest or absent')

  if ($class_manage and $ensure == 'present' or $ensure == 'latest')
  {
    class
    { '::apache':
      ensure_vhost => false,
    }

    contain ::apache
  }

  if ($vhost_manage and $ensure == 'present' or $ensure == 'latest')
  {
    ::apache::vhost
    { $vhost:
      ip            => '*',
      port          => $host_port,

      docroot       => $letsencrypt_dir_base,
      docroot_owner => $letsencrypt_dir_owner,
      docroot_group => $letsencrypt_dir_group,
      docroot_mode  => $letsencrypt_dir_mode,

      directories   =>
      [
        {
          path           => $letsencrypt_dir,
          provider       => 'directory',

          allow_override => 'None',
          require        => 'all denied',
        },
        {
          path           => "${letsencrypt_dir}/.well-known/acme-challenge",
          provider       => 'directory',

          options        => ['FollowSymLinks'],
          allow_override => 'None',
          require        => 'all granted',
        }
      ],
    }

    if ($directories_manage)
    {
      Class['::letsencrypt::directories'] -> ::Apache::Vhost[$vhost]
    }
  }
}
