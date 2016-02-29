# Class: letsencrypt::package
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
class letsencrypt::package
(
  $ensure = 'present',

  $provider = $::letsencrypt::params::package_provider,
  $source   = $::letsencrypt::params::package_source,
  $revision = $::letsencrypt::params::package_revision,

  $dir   = $::letsencrypt::params::package_dir,
  $owner = $::letsencrypt::params::package_owner,
  $group = $::letsencrypt::params::package_group,

) inherits letsencrypt::params
{
  validate_re($ensure, ['^present$', '^latest$', '^absent$'], 'ensure can only be one of present, latest or absent')

  vcsrepo
  { $package_dir:
    ensure   => $ensure,
    provider => $provider,
    source   => $source,
    revision => $revision,
    owner    => $owner,
    group    => $group,
  }
}
