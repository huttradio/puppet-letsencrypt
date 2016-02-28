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

  $environment         = undef,
  $environment_staging = false,

  $vhost_dir  = $::letsencrypt::params::vhost_dir,

  $letsencrypt_dir_base = $::letsencrypt::params::letsencrypt_dir_base,

  $letsencrypt_certs_dir_base = $::letsencrypt::params::letsencrypt_certs_dir_base,
  $letsencrypt_csrs_dir_base  = $::letsencrypt::params::letsencrypt_csrs_dir_base,

  $letsencrypt_certs_dir = undef,
  $letsencrypt_csrs_dir  = undef,

  $letsencrypt_certs_dir_owner = $::letsencrypt::params::letsencrypt_certs_dir_owner,
  $letsencrypt_certs_dir_group = $::letsencrypt::params::letsencrypt_certs_dir_group,
  $letsencrypt_certs_dir_mode  = $::letsencrypt::params::letsencrypt_certs_dir_mode,

  $letsencrypt_csrs_dir_owner = $::letsencrypt::params::letsencrypt_csrs_dir_owner,
  $letsencrypt_csrs_dir_group = $::letsencrypt::params::letsencrypt_csrs_dir_group,
  $letsencrypt_csrs_dir_mode  = $::letsencrypt::params::letsencrypt_csrs_dir_mode,

  $letsencrypt_sh         = $::letsencrypt::params::letsencrypt_sh,
  $letsencrypt_sh_dir     = $::letsencrypt::params::letsencrypt_sh_dir,
  $letsencrypt_sh_command = undef,

  $csr            = $::letsencrypt::params::letsencrypt_csr,
  $cert           = $::letsencrypt::params::letsencrypt_cert,
  $chain          = $::letsencrypt::params::letsencrypt_chain,
  $fullchain      = $::letsencrypt::params::letsencrypt_fullchain,
  $privkey        = $::letsencrypt::params::letsencrypt_privkey,

  $csr_path       = undef,
  $cert_path      = undef,
  $chain_path     = undef,
  $fullchain_path = undef,
  $privkey_path   = undef,

  $cert_owner  = $::letsencrypt::params::letsencrypt_cert_owner,
  $cert_group  = $::letsencrypt::params::letsencrypt_cert_group,
  $cert_mode   = $::letsencrypt::params::letsencrypt_cert_mode,

  $cron_manage  = true,
  $cron_command = undef,
  $cron_user    = undef,

  $false = $::letsencrypt::params::false,
  $test  = $::letsencrypt::params::test,
)
{
  $_letsencrypt_certs_dir = pick($letsencrypt_certs_dir, "${letsencrypt_certs_dir_base}/${servername}")
  $_letsencrypt_csrs_dir  = pick($letsencrypt_csrs_dir, "${letsencrypt_csrs_dir_base}/${servername}")

  $_csr_path       = pick($csr_path, "${_letsencrypt_csrs_dir}/${csr}")
  $_cert_path      = pick($cert_path, "${_letsencrypt_certs_dir}/${cert}")
  $_chain_path     = pick($chain_path, "${_letsencrypt_certs_dir}/${chain}")
  $_fullchain_path = pick($fullchain_path, "${_letsencrypt_certs_dir}/${fullchain}")
  $_privkey_path   = pick($privkey_path, "${_letsencrypt_certs_dir}/${privkey}")

  if ($environment_staging)
  {
    $_environment = pick($environment, $::letsencrypt::params::environment_staging)
  }
  else
  {
    $_environment = pick($environment, $::letsencrypt::params::environment_production)
  }

  $_letsencrypt_sh_command = pick($letsencrypt_sh_command, "'${letsencrypt_sh_dir}/${letsencrypt_sh}' '${_environment}' '${letsencrypt_dir_base}' '${vhost_dir}/.well-known/acme-challenge' '${email}' '${servername}' '${_csr_path}' '${_cert_path}' '${_chain_path}' '${_fullchain_path}'")

  validate_re($ensure, ['^present$', '^absent$'], 'ensure can only be one of present or absent')
  validate_re($email, '^[A-Za-z0-9][A-Za-z0-9_\.]*[A-Za-z0-9]@[A-Za-z0-9][0-9A-Za-z\-]*[A-Za-z0-9]\.[A-Za-z0-9][0-9A-Za-z\-\.]*[A-Za-z0-9]$', "${email} does not appear to be a valid email address")
  validate_bool($cron_manage)

  if ($ensure == 'present')
  {
    $directory_ensure = 'directory'
  }
  else
  {
    $directory_ensure = $ensure
  }

  # Create the directory where the CSRs will be stored.
  file
  { $_letsencrypt_csrs_dir:
    ensure => $directory_ensure,
    owner  => $letsencrypt_csrs_dir_owner,
    group  => $letsencrypt_csrs_dir_group,
    mode   => $letsencrypt_csrs_dir_mode,
  }

  # Create the directory where the certificates will be stored.
  file
  { $_letsencrypt_certs_dir:
    ensure => $directory_ensure,
    owner  => $letsencrypt_certs_dir_owner,
    group  => $letsencrypt_certs_dir_group,
    mode   => $letsencrypt_certs_dir_mode,
  }

  # Generate the private key, certificate and CSR.
  ::letsencrypt::cert::csr
  { $servername:
    email => $email,
    dir   => $_letsencrypt_csrs_dir,
  }

  # Generate the chain and fullchain certificates, by asking the Let's Encrypt
  # CA to sign our CSR.
  exec
  { "::letsencrypt::cert::create::${servername}":
    command => $_letsencrypt_sh_command,
    unless  => "${test} -f '$_cert_path' -a -f '$_chain_path' -a -f '$_fullchain_path'",
  }

  # Assertion to make sure that the certificate files were created.
  exec
  { "::letsencrypt::cert::assert::${servername}":
    command => "${false}",
    unless  => "${test} -f '$_cert_path' -a -f '$_chain_path' -a -f '$_fullchain_path'",
  }

  file
  { $_cert_path:
    ensure => $ensure,
    owner  => $cert_owner,
    group  => $cert_group,
    mode   => $cert_mode,
  }

  file
  { $_chain_path:
    ensure => $ensure,
    owner  => $cert_owner,
    group  => $cert_group,
    mode   => $cert_mode,
  }

  file
  { $_fullchain_path:
    ensure => $ensure,
    owner  => $cert_owner,
    group  => $cert_group,
    mode   => $cert_mode,
  }

  file
  { $_privkey_path:
    ensure    => $ensure,
    show_diff => false,
    owner     => $privkey_owner,
    group     => $privkey_group,
    mode      => $privkey_mode,
  }

  File[$_letsencrypt_csrs_dir] -> ::Letsencrypt::Cert::Csr[$servername]

  File[$_letsencrypt_certs_dir]         -> Exec["::letsencrypt::cert::create::${servername}"]
  ::Letsencrypt::Cert::Csr[$servername] ~> Exec["::letsencrypt::cert::create::${servername}"]

  Exec["::letsencrypt::cert::create::${servername}"] -> Exec["::letsencrypt::cert::assert::${servername}"]

  Exec["::letsencrypt::cert::assert::${servername}"] -> File[$_cert_path]
  Exec["::letsencrypt::cert::assert::${servername}"] -> File[$_chain_path]
  Exec["::letsencrypt::cert::assert::${servername}"] -> File[$_fullchain_path]
  Exec["::letsencrypt::cert::assert::${servername}"] -> File[$_privkey_path]

  if ($package_manage)
  {
    Class['::letsencrypt::package'] -> Exec["::letsencrypt::cert::create::${servername}"]
  }

  if ($directories_manage)
  {
    Class['::letsencrypt::directories'] -> Exec["::letsencrypt::cert::create::${servername}"]
  }

  if ($apache_manage)
  {
    Class['::letsencrypt::apache'] -> Exec["::letsencrypt::cert::create::${servername}"]
  }
}
