# Class: letsencrypt::directories
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
class letsencrypt::directories
(
  $ensure = 'present',

  $letsencrypt_dir_base  = $::letsencrypt::params::letsencrypt_dir_base,
  $letsencrypt_dir_owner = $::letsencrypt::params::letsencrypt_dir_owner,
  $letsencrypt_dir_group = $::letsencrypt::params::letsencrypt_dir_group,
  $letsencrypt_dir_mode  = $::letsencrypt::params::letsencrypt_dir_mode,

  $letsencrypt_csrs_dir_base  = $::letsencrypt::params::letsencrypt_csrs_dir_base,
  $letsencrypt_csrs_dir_owner = $::letsencrypt::params::letsencrypt_csrs_dir_owner,
  $letsencrypt_csrs_dir_group = $::letsencrypt::params::letsencrypt_csrs_dir_group,
  $letsencrypt_csrs_dir_mode  = $::letsencrypt::params::letsencrypt_csrs_dir_mode,

  $letsencrypt_certs_dir_base  = $::letsencrypt::params::letsencrypt_certs_dir_base,
  $letsencrypt_certs_dir_owner = $::letsencrypt::params::letsencrypt_certs_dir_owner,
  $letsencrypt_certs_dir_group = $::letsencrypt::params::letsencrypt_certs_dir_group,
  $letsencrypt_certs_dir_mode  = $::letsencrypt::params::letsencrypt_certs_dir_mode,

  $letsencrypt_scripts_dir_base  = $::letsencrypt::params::letsencrypt_scripts_dir_base,
  $letsencrypt_scripts_dir_owner = $::letsencrypt::params::letsencrypt_scripts_dir_owner,
  $letsencrypt_scripts_dir_group = $::letsencrypt::params::letsencrypt_scripts_dir_group,
  $letsencrypt_scripts_dir_mode  = $::letsencrypt::params::letsencrypt_scripts_dir_mode,
) inherits letsencrypt::params
{
  validate_re($ensure, ['^present$', '^absent$'], 'ensure can only be one of present or absent')

  if ($ensure == 'present')
  {
    $directory_ensure = 'directory'
  }
  else
  {
    $directory_ensure = $ensure
  }

  file
  { $letsencrypt_dir_base:
    ensure => $directory_ensure,
    owner  => $letsencrypt_dir_owner,
    group  => $letsencrypt_dir_group,
    mode   => $letsencrypt_dir_mode,
  }

  file
  { $letsencrypt_csrs_dir_base:
    ensure => $directory_ensure,
    owner  => $letsencrypt_csrs_dir_owner,
    group  => $letsencrypt_csrs_dir_group,
    mode   => $letsencrypt_csrs_dir_mode,
  }

  file
  { $letsencrypt_certs_dir_base:
    ensure => $directory_ensure,
    owner  => $letsencrypt_certs_dir_owner,
    group  => $letsencrypt_certs_dir_group,
    mode   => $letsencrypt_certs_dir_mode,
  }

  file
  { $letsencrypt_scripts_dir_base:
    ensure => $directory_ensure,
    owner  => $letsencrypt_scripts_dir_owner,
    group  => $letsencrypt_scripts_dir_group,
    mode   => $letsencrypt_scripts_dir_mode,
  }
}
