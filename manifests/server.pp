# Class: letsencrypt::server
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
class letsencrypt::server
(
  $ensure = 'present',

  $package_manage        = true,
  $package_source        = $::letsencrypt::params::package_source,
  $package_package       = $::letsencrypt::params::package_package,
  $package_repo_path     = $::letsencrypt::params::package_repo_path,
  $package_repo_provider = $::letsencrypt::params::package_repo_provider,
  $package_repo_source   = $::letsencrypt::params::package_repo_source,
  $package_repo_revision = $::letsencrypt::params::package_repo_revision,

  $apache_manage  = true,
  $apache_package = $::letsencrypt::params::apache_package,

  $exported_certs_manage = true,
) inherits letsencrypt::params
{
  validate_re($ensure, ['^present$', '^latest$', '^absent$'], 'ensure can only be one of present, latest or absent')
  validate_bool($package_manage, $apache_manage, $cron_manage, $exported_certs_manage)

  if ($package_manage)
  {
    class
    { '::letsencrypt::server::package':
        ensure        => $ensure,
        source        => $package_source,
        package       => $package_package,
        epel          => $package_epel,
        repo_path     => $package_repo_path,
        repo_provider => $package_repo_provider,
        repo_source   => $package_repo_source,
        repo_revision => $package_repo_revision,
    }
  }

  if ($apache_manage)
  {
    class
    { '::letsencrypt::server::apache':
      ensure  => $ensure,
      package => $apache_package,
    }
  }

  if ($exported_certs_manage)
  {
    ::Letsencrypt::Cert::Server <<| |>>
  }
}
