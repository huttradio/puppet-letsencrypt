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
define letsencrypt::cert::csr
(
  $email,
  $dir,

  $ensure = 'present',

  $servername = $name,

  $letsencrypt_privkey_path  = undef,
  $letsencrypt_privkey       = $::letsencrypt::params::letsencrypt_privkey,
  $letsencrypt_privkey_owner = $::letsencrypt::params::letsencrypt_privkey_owner,
  $letsencrypt_privkey_group = $::letsencrypt::params::letsencrypt_privkey_group,
  $letsencrypt_privkey_mode  = $::letsencrypt::params::letsencrypt_privkey_mode,

  $letsencrypt_cert_cnf_path  = undef,
  $letsencrypt_cert_cnf       = $::letsencrypt::params::letsencrypt_cert_cnf,
  $letsencrypt_cert_cnf_owner = $::letsencrypt::params::letsencrypt_cert_cnf_owner,
  $letsencrypt_cert_cnf_group = $::letsencrypt::params::letsencrypt_cert_cnf_group,
  $letsencrypt_cert_cnf_mode  = $::letsencrypt::params::letsencrypt_cert_cnf_mode,

  $letsencrypt_csr_path  = undef,
  $letsencrypt_csr       = $::letsencrypt::params::letsencrypt_csr,
  $letsencrypt_csr_owner = $::letsencrypt::params::letsencrypt_csr_owner,
  $letsencrypt_csr_group = $::letsencrypt::params::letsencrypt_csr_group,
  $letsencrypt_csr_mode  = $::letsencrypt::params::letsencrypt_csr_mode,

  $false = $::letsencrypt::params::false,
  $test  = $::letsencrypt::params::test,
)
{
  $_letsencrypt_privkey_path  = pick($letsencrypt_privkey_path, "${dir}/${letsencrypt_privkey}")
  $_letsencrypt_cert_cnf_path = pick($letsencrypt_cert_cnf_path, "${dir}/${letsencrypt_cert_cnf}")
  $_letsencrypt_csr_path      = pick($letsencrypt_csr_path, "${dir}/${letsencrypt_csr}")

  if ($ensure == 'present')
  {
    $file_ensure = 'file'
  }
  else
  {
    $file_ensure = $ensure
  }

  validate_re($ensure, ['^present$', '^absent$'], 'ensure can only be one of present or absent')

  # Generate private key.
  ssl_pkey
  { $_letsencrypt_privkey_path:
    ensure => $ensure,
  }

  exec
  { "::letsencrypt::cert::csr::assert::ssl_pkey::${servername}":
    command => "${false}",
    unless  => "${test} -f '${_letsencrypt_privkey_path}'",
  }

  file
  { $_letsencrypt_privkey_path:
    ensure    => $file_ensure,
    show_diff => false,
    owner     => $letsencrypt_privkey_owner,
    group     => $letsencrypt_privkey_group,
    mode      => $letsencrypt_privkey_mode,
  }

  # Generate OpenSSL configuration for CSR.
  file
  { $_letsencrypt_cert_cnf_path:
    ensure  => $file_ensure,
    content => template('letsencrypt/cert.cnf.erb'),
    owner   => $letsencrypt_cert_cnf_owner,
    group   => $letsencrypt_cert_cnf_group,
    mode    => $letsencrypt_cert_cnf_mode,
  }

  # Generate CSR.
  x509_request
  { $_letsencrypt_csr_path:
    ensure      => $ensure,
    template    => $_letsencrypt_cert_cnf_path,
    private_key => $_letsencrypt_privkey_path,
    force       => true,
  }

  exec
  { "::letsencrypt::cert::csr::assert::x509_request::${servername}":
    command => "${false}",
    unless  => "${test} -f '${_letsencrypt_csr_path}'",
  }

  file
  { $_letsencrypt_csr_path:
    ensure => $file_ensure,
    owner  => $letsencrypt_csr_owner,
    group  => $letsencrypt_csr_group,
    mode   => $letsencrypt_csr_mode,
  }

  Ssl_pkey[$_letsencrypt_privkey_path] -> Exec["::letsencrypt::cert::csr::assert::ssl_pkey::${servername}"] -> File[$_letsencrypt_privkey_path]

  File[$_letsencrypt_privkey_path]   > X509_request[$_letsencrypt_csr_path]
  File[$_letsencrypt_cert_cnf_path] -> X509_request[$_letsencrypt_csr_path]

  X509_request[$_letsencrypt_csr_path] -> Exec["::letsencrypt::cert::csr::assert::x509_request::${servername}"] -> File[$_letsencrypt_csr_path]
}
