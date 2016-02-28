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

  $vhost_dir  = $::letsencrypt::params::vhost_dir,

  $vhost_dir_owner = $::letsencrypt::params::vhost_dir_owner,
  $vhost_dir_group = $::letsencrypt::params::vhost_dir_group,
  $vhost_dir_mode  = $::letsencrypt::params::vhost_dir_mode,
) inherits letsencrypt::params
{
  validate_re($ensure, ['^present$', '^latest$', '^absent$'], 'ensure can only be one of present, latest or absent')

  if ($ensure == 'present' or $ensure == 'latest')
  {
    $directory_ensure = 'directory'
  }
  else
  {
    $directory_ensure = $ensure
  }

  if ($class_manage and $ensure == 'present' or $ensure == 'latest')
  {
    class
    { '::apache':
      ensure_vhost => false,
    }

    contain ::apache
  }

  if ($vhost_manage)
  {
    if ($ensure == 'present' or $ensure == 'latest')
    {
      ::apache::vhost
      { $vhost:
        ip            => '*',
        port          => $vhost_port,

        docroot       => $vhost_dir,
        docroot_owner => $vhost_dir_owner,
        docroot_group => $vhost_dir_group,
        docroot_mode  => $vhost_dir_mode,

        directories   =>
        [
          {
            path           => "$vhost_dir/.well-known/acme-challenge",
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

    file
    { [$vhost_dir, "${vhost_dir}/.well-known", "${vhost_dir}/.well-known/acme-challenge"]:
      ensure => $directory_ensure,
      owner  => $vhost_dir_owner,
      group  => $vhost_dir_group,
      mode   => $vhost_dir_mode,
    }
  }
}
