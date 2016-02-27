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
  $ensure = 'present',

  $letsencrypt_dir       = $::letsencrypt::params::letsencrypt_dir,
  $letsencrypt_dir_owner = $::letsencrypt::params::letsencrypt_dir_owner,
  $letsencrypt_dir_group = $::letsencrypt::params::letsencrypt_dir_group,

  $letsencrypt_sh        = $::letsencrypt::params::letsencrypt_sh,
  $letsencrypt_sh_source = $::letsencrypt::params::letsencrypt_sh_source,
  $letsencrypt_sh_owner  = $::letsencrypt::params::letsencrypt_sh_owner,
  $letsencrypt_sh_group  = $::letsencrypt::params::letsencrypt_sh_group,
  $letsencrypt_sh_mode   = $::letsencrypt::params::letsencrypt_sh_mode,

  $repo_provider  = $::letsencrypt::params::package_repo_provider,
  $repo_source    = $::letsencrypt::params::package_repo_source,
  $repo_revision  = $::letsencrypt::params::package_repo_revision,
) inherits letsencrypt::params
{
  validate_re($ensure, ['^present$', '^latest$', '^absent$'], 'ensure can only be one of present, latest or absent')

  if ($ensure == 'present' or $ensure == 'latest')
  {
    $file_ensure = 'file'
  }
  else
  {
    $file_ensure = $ensure
  }

  vcsrepo
  { $letsencrypt_dir:
    ensure   => $ensure,
    provider => $repo_provider,
    source   => $repo_source,
    revision => $repo_revision,
    owner    => $letsencrypt_dir_owner,
    group    => $letsencrypt_dir_group,
  }

  file
  { $letsencrypt_sh:
    ensure => $file_ensure,
    source => $letsencrypt_sh_source,
    owner  => $letsencrypt_sh_owner,
    group  => $letsencrypt_sh_group,
    mode   => $letsencrypt_sh_mode,
  }
}
