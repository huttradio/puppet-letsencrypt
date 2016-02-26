# Class: letsencrypt::server::package
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
class letsencrypt::server::package
(
  $ensure            = 'present',
  $assert_base_class = true,

  $source = $::letsencrypt::params::package_source,

  $repo_path     = $::letsencrypt::params::package_repo_path,
  $repo_provider = $::letsencrypt::params::package_repo_provider,
  $repo_source   = $::letsencrypt::params::package_repo_source,
  $repo_revision = $::letsencrypt::params::package_repo_revision,
) inherits letsencrypt::params
{
  validate_re($ensure, ['^present$', '^latest$', '^absent$'], 'ensure can only be one of present, latest or absent')
  validate_re($source, ['^package$', '^vcsrepo$'], 'source can only be one of package or vcsrepo')

  if ($source == 'package')
  {
    validate_re($package, '^[^[[:space:]]][^[[:space:]]]*$', 'package does not appear to be a valid package name')

    package
    { $package:
      ensure => $ensure,
    }
  }
  elsif ($source == 'vcsrepo')
  {
    vcsrepo
    { $repo_path:
      ensure   => $ensure,
      provider => $repo_provider,
      source   => $repo_source,
      revision => $repo_revision,
    }
  }
}
