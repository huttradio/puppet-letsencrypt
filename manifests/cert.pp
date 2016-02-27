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
define letsencrypt::cert
(
  $email,

  $ensure = 'present',

  $servername = $name,

  $package_manage     = true,
  $directories_manage = true,
  $apache_manage      = true,

  $letsencrypt_dir_base  = $::letsencrypt::params::letsencrypt_dir_base,
  $letsencrypt_dir       = undef,
  $letsencrypt_dir_owner = $::letsencrypt::params::letsencrypt_dir_owner,
  $letsencrypt_dir_group = $::letsencrypt::params::letsencrypt_dir_group,
  $letsencrypt_dir_mode  = $::letsencrypt::params::letsencrypt_dir_mode,

  $letsencrypt_sh         = $::letsencrypt::params::letsencrypt_sh,
  $letsencrypt_sh_dir     = $::letsencrypt::params::letsencrypt_sh_dir,
  $letsencrypt_sh_command = undef,

  $cert           = $::letsencrypt::params::letsencrypt_cert,
  $chain          = $::letsencrypt::params::letsencrypt_chain,
  $fullchain      = $::letsencrypt::params::letsencrypt_fullchain,
  $privkey        = $::letsencrypt::params::letsencrypt_privkey,

  $cert_path      = undef,
  $chain_path     = undef,
  $fullchain_path = undef,
  $privkey_path   = undef,

  $cert_owner  = $::letsncrypt::params::letsncrypt_cert_owner,
  $cert_group  = $::letsncrypt::params::letsncrypt_cert_group,
  $cert_mode   = $::letsncrypt::params::letsncrypt_cert_mode,

  $privkey_owner  = $::letsncrypt::params::letsncrypt_privkey_owner,
  $privkey_group  = $::letsncrypt::params::letsncrypt_privkey_group,
  $privkey_mode   = $::letsncrypt::params::letsncrypt_privkey_mode,

  $cron_manage  = true,
  $cron_command = undef,
  $cron_user    = undef,
)
{
  $_letsencrypt_sh_command = pick($letsencrypt_sh_command, "${letsencrypt_sh_dir}/${letsencrypt_sh} ${letsencrypt_dir} ${email} ${servername}")

  $_letsencrypt_dir = pick($letsencrypt_dir, "${letsencrypt_dir_base}/certs/${servername}")

  $_cert_path      = pick($cert_path, "${_letsencrypt_dir}/${cert}")
  $_chain_path     = pick($chain_path, "${_letsencrypt_dir}/${chain}")
  $_fullchain_path = pick($fullchain_path, "${_letsencrypt_dir}/${fullchain}")
  $_privkey_path   = pick($privkey_path, "${_letsencrypt_dir}/${privkey}")

  validate_re($ensure, ['^present$', '^absent$'], 'ensure can only be one of present or absent')
  validate_re($email, '^[A-Za-z0-9][A-Za-z0-9_\.]*[A-Za-z0-9]@[A-Za-z0-9][0-9A-Za-z\-]*[A-Za-z0-9]\.[A-Za-z0-9][0-9A-Za-z\-\.]*[A-Za-z0-9]$', "${email} does not appear to be a valid email address")
  validate_bool($cron_manage)

  if ($ensure == 'present')
  {
    $directory_ensure = 'directory'
    $file_ensure      = 'file'
  }
  else
  {
    $directory_ensure = $ensure
    $file_ensure      = $ensure
  }

  exec
  { "::letsencrypt::cert::${servername}":
    command => $_letsencrypt_sh_command,
    creates => [ $_cert_path, $_chain_path, $_fullchain_path, $_privkey_path ],
  }

  file
  { $_letsencrypt_dir:
    ensure  => $directory_ensure,
    owner   => $letsencrypt_dir_owner,
    group   => $letsencrypt_dir_group,
    mode    => $letsencrypt_dir_mode,
  }

  file
  { $_cert_path:
    ensure  => $file_ensure,
    owner   => $_cert_owner,
    group   => $_cert_group,
    mode    => $_cert_mode,
  }

  file
  { $_chain_path:
    ensure  => $file_ensure,
    owner   => $_cert_owner,
    group   => $_cert_group,
    mode    => $_cert_mode,
  }

  file
  { $_fullchain_path:
    ensure  => $file_ensure,
    owner   => $_cert_owner,
    group   => $_cert_group,
    mode    => $_cert_mode,
  }

  file
  { $_privkey_path:
    ensure    => $file_ensure,
    show_diff => false,
    owner     => $_privkey_owner,
    group     => $_privkey_group,
    mode      => $_privkey_mode,
  }

  Exec["::letsencrypt::cert::${servername}"] -> File[$_cert_path]
  Exec["::letsencrypt::cert::${servername}"] -> File[$_chain_path]
  Exec["::letsencrypt::cert::${servername}"] -> File[$_fullchain_path]
  Exec["::letsencrypt::cert::${servername}"] -> File[$_privkey_path]

  if ($package_manage)
  {
    Class['::letsencrypt::package'] -> Exec["::letsencrypt::cert::${servername}"]
  }

  if ($directories_manage)
  {
    Class['::letsencrypt::directories'] -> Exec["::letsencrypt::cert::${servername}"]
  }

  if ($apache_manage)
  {
    Class['::letsencrypt::apache'] -> Exec["::letsencrypt::cert::${servername}"]
  }
}
