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

  $letsencrypt         = undef,
  $letsencrypt_dir     = undef,
  $letsencrypt_command = undef,

  $cert_dir_base  = undef,
  $cert_dir       = undef,
  $cert           = undef,
  $chain          = undef,
  $fullchain      = undef,
  $privkey        = undef,
  $cert_path      = undef,
  $chain_path     = undef,
  $fullchain_path = undef,
  $privkey_path   = undef,

  $cert_dir_manage = false,
  $cert_dir_owner  = undef,
  $cert_dir_group  = undef,
  $cert_dir_mode   = undef,

  $cert_owner  = undef,
  $cert_group  = undef,
  $cert_mode   = undef,

  $privkey_owner  = undef,
  $privkey_group  = undef,
  $privkey_mode   = undef,

  $cert_dir_base_server  = undef,
  $cert_dir_server       = undef,
  $cert_server           = undef,
  $chain_server          = undef,
  $fullchain_server      = undef,
  $privkey_server        = undef,
  $cert_path_server      = undef,
  $chain_path_server     = undef,
  $fullchain_path_server = undef,
  $privkey_path_server   = undef,

  $cron_manage  = true,
  $cron_command = undef,
  $cron_user    = undef,
)
{
  require ::letsencrypt::params

  $_letsencrypt         = pick($letsencrypt, $::letsencrypt::params::letsencrypt)
  $_letsencrypt_dir     = pick($letsencrypt_dir, $::letsencrypt::params::letsencrypt_dir)
  $_letsencrypt_command = pick($command, "${_letsencrypt_dir}/${_letsencrypt} --agree-tos --email ${email} --apache -d ${servername}")

  $_cert_dir_base  = pick($cert_dir_base, $::letsencrypt::params::letsencrypt_cert_dir_base)
  $_cert_dir       = pick($cert_dir, "${_cert_dir_base}/${servername}")
  $_cert           = pick($cert, $::letsencrypt::params::letsencrypt_cert)
  $_chain          = pick($chain, $::letsencrypt::params::letsencrypt_chain)
  $_fullchain      = pick($fullchain, $::letsencrypt::params::letsencrypt_fullchain)
  $_privkey        = pick($privkey, $::letsencrypt::params::letsencrypt_privkey)
  $_cert_path      = pick($cert_path, "${_cert_dir}/${_cert}")
  $_chain_path     = pick($chain_path, "${_cert_dir}/${_chain}")
  $_fullchain_path = pick($fullchain_path, "${_cert_dir}/${_fullchain}")
  $_privkey_path   = pick($privkey_path, "${_cert_dir}/${_privkey}")

  $_cert_dir_owner  = pick($cert_dir_owner, $::letsencrypt::params::letsencrypt_cert_dir_owner)
  $_cert_dir_group  = pick($cert_dir_group, $::letsencrypt::params::letsencrypt_cert_dir_group)
  $_cert_dir_mode   = pick($cert_dir_mode, $::letsencrypt::params::letsencrypt_cert_dir_mode)

  $_cert_owner  = pick($cert_owner, $::letsencrypt::params::letsencrypt_cert_owner)
  $_cert_group  = pick($cert_group, $::letsencrypt::params::letsencrypt_cert_group)
  $_cert_mode   = pick($cert_mode, $::letsencrypt::params::letsencrypt_cert_mode)

  $_privkey_owner  = pick($privkey_owner, $::letsencrypt::params::letsencrypt_privkey_owner)
  $_privkey_group  = pick($privkey_group, $::letsencrypt::params::letsencrypt_privkey_group)
  $_privkey_mode   = pick($privkey_mode, $::letsencrypt::params::letsencrypt_privkey_mode)

  $_cert_dir_base_server  = pick($cert_dir_base_server, $::letsencrypt::params::letsencrypt_cert_dir_base)
  $_cert_dir_server       = pick($cert_dir_server, "${_cert_dir_base_server}/${servername}")
  $_cert_server           = pick($cert_server, $::letsencrypt::params::letsencrypt_cert)
  $_chain_server          = pick($chain_server, $::letsencrypt::params::letsencrypt_chain)
  $_fullchain_server      = pick($fullchain_server $::letsencrypt::params::letsencrypt_fullchain)
  $_privkey_server        = pick($privkey_server, $::letsencrypt::params::letsencrypt_privkey)
  $_cert_path_server      = pick($cert_path_server, "${_cert_dir_server}/${_cert_server}")
  $_chain_path_server     = pick($chain_path_server, "${_cert_dir_server}/${_chain_server}")
  $_fullchain_path_server = pick($fullchain_path_server, "${_cert_dir_server}/${_fullchain_server}")
  $_privkey_path_server   = pick($privkey_path_server, "${_cert_dir_server}/${_privkey_server}")

  $_cron_command = pick($cron_command, "${_letsencrypt_command} --keep-until-expiring")
  $_cron_user    = pick($cron_user, $::letsencrypt::params::cron_user)

  validate_re($ensure, ['^present$', '^absent$'], 'ensure can only be one of present or absent')
  validate_re($email, '^[A-Za-z0-9][A-Za-z0-9_\.]*[A-Za-z0-9]@[A-Za-z0-9][0-9A-Za-z\-]*[A-Za-z0-9]\.[A-Za-z0-9][0-9A-Za-z\-\.]*[A-Za-z0-9]$', "${email} does not appear to be a valid email address")
  validate_bool($cron_manage, $cert_dir_manage)

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

  unless (file_exists($_cert_path_server) and file_exists($_chain_path_server) and file_exists($_fullchain_path_server) and file_exists($_privkey_path_server))
  {
    generate($_letsencrypt_command)
  }

  if ($manage_cert_dir)
  {
    file
    { $_cert_dir:
      ensure  => $directory_ensure,
      owner   => $_cert_dir_owner,
      group   => $_cert_dir_group,
      mode    => $_cert_dir_mode,
    }
  }

  file
  { $_cert_path:
    ensure  => $file_ensure,
    content => file($_cert_path_server),
    owner   => $_cert_owner,
    group   => $_cert_group,
    mode    => $_cert_mode,
  }

  file
  { $_chain_path:
    ensure  => $file_ensure,
    content => file($_chain_path_server),
    owner   => $_cert_owner,
    group   => $_cert_group,
    mode    => $_cert_mode,
  }

  file
  { $_fullchain_path:
    ensure  => $file_ensure,
    content => file($_fullchain_path_server),
    owner   => $_cert_owner,
    group   => $_cert_group,
    mode    => $_cert_mode,
  }

  file
  { $_privkey_path:
    ensure    => $file_ensure,
    content   => file($_privkey_path_server),
    show_diff => false,
    owner     => $_privkey_owner,
    group     => $_privkey_group,
    mode      => $_privkey_mode,
  }

  @@::letsencrypt::cert::server
  { $name:
    cron_manage  => $cron_manage,
    cron_command => $_cron_command,
    cron_user    => $_cron_user,
  }
}
