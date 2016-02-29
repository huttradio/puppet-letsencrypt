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
define letsencrypt::cert::generate
(
  # Parameters required by the wrapper script.
  $environment,
  $email,
  $letsencrypt_csr_path,
  $letsencrypt_script_path = undef,
  $letsencrypt_dir_base    = $::letsencrypt::params::letsencrypt_dir_base,
  $acme_challenge_dir      = undef,
  $servername              = $name,

  # Can be 'present' or 'absent'.
  $ensure = 'present',

  # Used for generating the location for letsencrypt.sh.
  $package_dir = $::letsencrypt::params::package_dir,

  $package_path = undef,
  $package = $::letsencrypt::params::package,

  # Used for generating acme_challenge_dir.
  $vhost_dir = $::letsencrypt::params::vhost_dir,

  # Directory overrides, bases and permissions.
  $letsencrypt_certs_dir       = undef,
  $letsencrypt_certs_dir_base  = $::letsencrypt::params::letsencrypt_certs_dir_base,
  $letsencrypt_certs_dir_owner = $::letsencrypt::params::letsencrypt_certs_dir_owner,
  $letsencrypt_certs_dir_group = $::letsencrypt::params::letsencrypt_certs_dir_group,
  $letsencrypt_certs_dir_mode  = $::letsencrypt::params::letsencrypt_certs_dir_mode,

  $letsencrypt_scripts_dir_base  = $::letsencrypt::params::letsencrypt_scripts_dir_base,
  $letsencrypt_scripts_dir_owner = $::letsencrypt::params::letsencrypt_scripts_dir_owner,
  $letsencrypt_scripts_dir_group = $::letsencrypt::params::letsencrypt_scripts_dir_group,
  $letsencrypt_scripts_dir_mode  = $::letsencrypt::params::letsencrypt_scripts_dir_mode,

  $letsencrypt_script          = $::letsencrypt::params::letsencrypt_script,
  $letsencrypt_script_template = $::letsencrypt::params::letsencrypt_script_template,
  $letsencrypt_script_owner    = $::letsencrypt::params::letsencrypt_script_owner,
  $letsencrypt_script_group    = $::letsencrypt::params::letsencrypt_script_group,
  $letsencrypt_script_mode     = $::letsencrypt::params::letsencrypt_script_mode,

  # Certificate path overrides, filenames and permissions.
  $letsencrypt_cert_path = undef,
  $letsencrypt_cert      = $::letsencrypt::params::letsencrypt_cert,

  $letsencrypt_chain_path = undef,
  $letsencrypt_chain      = $::letsencrypt::params::letsencrypt_chain,

  $letsencrypt_fullchain_path = undef,
  $letsencrypt_fullchain      = $::letsencrypt::params::letsencrypt_fullchain,

  $letsencrypt_cert_owner = $::letsencrypt::params::letsencrypt_cert_owner,
  $letsencrypt_cert_group = $::letsencrypt::params::letsencrypt_cert_group,
  $letsencrypt_cert_mode  = $::letsencrypt::params::letsencrypt_cert_mode,

  # Private key overrides, filenames and permissions.
  $letsencrypt_privkey_path = undef,
  $letsencrypt_privkey      = $::letsencrypt::params::letsencrypt_privkey,

  $letsencrypt_privkey_owner = $::letsencrypt::params::letsencrypt_privkey_owner,
  $letsencrypt_privkey_group = $::letsencrypt::params::letsencrypt_privkey_group,
  $letsencrypt_privkey_mode  = $::letsencrypt::params::letsencrypt_privkey_mode,

  # Command names.
  $false = $::letsencrypt::params::false,
  $test  = $::letsencrypt::params::test,
)
{
  $_letsencrypt_scripts_dir = pick($letsencrypt_scripts_dir, "${letsencrypt_scripts_dir_base}/${servername}")
  $_letsencrypt_script_path = pick($letsencrypt_script_path, "${_letsencrypt_scripts_dir}/${letsencrypt_script}")

  $_package_path = pick($package_path, "${package_dir}/${package}")

  $_acme_challenge_dir = pick($acme_challenge_dir, "${vhost_dir}/.well-known/acme-challenge")

  $_letsencrypt_certs_dir      = pick($letsencrypt_certs_dir, "${letsencrypt_certs_dir_base}/${servername}")
  $_letsencrypt_cert_path      = pick($letsencrypt_cert_path, "${_letsencrypt_certs_dir}/${letsencrypt_cert}")
  $_letsencrypt_chain_path     = pick($letsencrypt_chain_path, "${_letsencrypt_certs_dir}/${letsencrypt_chain}")
  $_letsencrypt_fullchain_path = pick($letsencrypt_fullchain_path, "${_letsencrypt_certs_dir}/${letsencrypt_fullchain}")
  $_letsencrypt_privkey_path   = pick($letsencrypt_privkey_path, "${_letsencrypt_certs_dir}/${letsencrypt_privkey}")

  if ($ensure == 'present')
  {
    $directory_ensure = 'directory'
    $file_ensure      = 'file'
  }
  else
  {
    $file_ensure = $ensure
  }

  validate_re($ensure, ['^present$', '^absent$'], 'ensure can only be one of present or absent')

  # Create the directory where the certificates will be stored.
  file
  { $_letsencrypt_certs_dir:
    ensure => $directory_ensure,
    owner  => $letsencrypt_certs_dir_owner,
    group  => $letsencrypt_certs_dir_group,
    mode   => $letsencrypt_certs_dir_mode,
  }

  # Install the letsencrypt-sh wrapper script for this servername.
  file
  { $_letsencrypt_scripts_dir:
    ensure => $directory_ensure,
    owner  => $letsencrypt_scripts_dir_owner,
    group  => $letsencrypt_scripts_dir_group,
    mode   => $letsencrypt_scripts_dir_mode,
  }

  file
  { $_letsencrypt_script_path:
    ensure  => $file_ensure,
    content => template($letsencrypt_script_template),
    owner   => $letsencrypt_script_owner,
    group   => $letsencrypt_script_group,
    mode    => $letsencrypt_script_mode,
  }

  # Run the wrapper script to get the Let's Encrypt CA to sign the CSR.
  exec
  { "::letsencrypt::cert::generate::create::${servername}":
    command => $_letsencrypt_script_path,
    unless  => "${test} -f '$_letsencrypt_cert_path' -a -f '$_letsencrypt_chain_path' -a -f '$_letsencrypt_fullchain_path'",
  }

  # Assertion to make sure that the certificate files were created.
  exec
  { "::letsencrypt::cert::generate::assert::${servername}":
    command => "${false}",
    unless  => "${test} -f '$_letsencrypt_cert_path' -a -f '$_letsencrypt_chain_path' -a -f '$_letsencrypt_fullchain_path'",
  }

  file
  { $_letsencrypt_cert_path:
    ensure => $ensure,
    owner  => $letsencrypt_cert_owner,
    group  => $letsencrypt_cert_group,
    mode   => $letsencrypt_cert_mode,
  }

  file
  { $_letsencrypt_chain_path:
    ensure => $ensure,
    owner  => $letsencrypt_cert_owner,
    group  => $letsencrypt_cert_group,
    mode   => $letsencrypt_cert_mode,
  }

  file
  { $_letsencrypt_fullchain_path:
    ensure => $ensure,
    owner  => $letsencrypt_cert_owner,
    group  => $letsencrypt_cert_group,
    mode   => $letsencrypt_cert_mode,
  }

  file
  { $_letsencrypt_privkey_path:
    ensure    => $ensure,
    show_diff => false,
    owner     => $letsencrypt_privkey_owner,
    group     => $letsencrypt_privkey_group,
    mode      => $letsencrypt_privkey_mode,
  }

  File[$_letsencrypt_certs_dir]   -> Exec["::letsencrypt::cert::generate::create::${servername}"]
  File[$_letsencrypt_script_path] -> Exec["::letsencrypt::cert::generate::create::${servername}"]

  Exec["::letsencrypt::cert::generate::create::${servername}"] -> Exec["::letsencrypt::cert::generate::assert::${servername}"]

  Exec["::letsencrypt::cert::generate::assert::${servername}"] -> File[$_letsencrypt_cert_path]
  Exec["::letsencrypt::cert::generate::assert::${servername}"] -> File[$_letsencrypt_chain_path]
  Exec["::letsencrypt::cert::generate::assert::${servername}"] -> File[$_letsencrypt_fullchain_path]
  Exec["::letsencrypt::cert::generate::assert::${servername}"] -> File[$_letsencrypt_privkey_path]
}
