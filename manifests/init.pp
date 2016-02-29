# Class: letsencrypt
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
class letsencrypt
(
  $ensure = 'present',

  $package_manage = true,

  $directories_manage = true,

  $vhost      = $::letsencrypt::params::vhost,
  $vhost_port = $::letsencrypt::params::vhost_port,

  $apache_manage       = true,
  $apache_class_manage = true,
  $apache_vhost_manage = true,

  # TODO: nginx_manage

  $email   = undef,
  $domains = undef,
) inherits letsencrypt::params
{
  validate_re($ensure, ['^present$', '^latest$', '^absent$'], 'ensure can only be one of present, latest or absent')
  validate_bool($package_manage, $directories_manage, $apache_manage, $apache_class_manage, $apache_vhost_manage)

  if ($ensure == 'latest')
  {
    $present_ensure = 'present'
  }
  else
  {
    $present_ensure = $ensure
  }

  if ($package_manage)
  {
    class
    { '::letsencrypt::package':
        ensure => $ensure,
    }
  }

  if ($directories_manage)
  {
    class
    { '::letsencrypt::directories':
        ensure => $present_ensure,
    }
  }

  if ($apache_manage)
  {
    class
    { '::letsencrypt::apache':
      ensure             => $present_ensure,
      class_manage       => $apache_class_manage,
      vhost_manage       => $apache_vhost_manage,

      vhost              => $vhost,
      vhost_port         => $vhost_port,

      directories_manage => $directories_manage,
    }
  }

  if ($domains != undef)
  {
    if (!is_string($domains) and !is_array($domains))
    {
      fail("if defined, domains should be either a String or Array of Strings")
    }

    ::letsencrypt::cert
    { $domains:
      ensure             => $present_ensure,
      email              => $email,

      package_manage     => $package_manage,
      directories_manage => $directories_manage,
      apache_manage      => $apache_manage,
    }
  }
}
