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

  $privkey  = $::letsencrypt::params::letsencrypt_privkey,
  $cert_cnf = $::letsencrypt::params::letsencrypt_cert_cnf,
  $csr      = $::letsencrypt::params::letsencrypt_csr,

  $privkey_path  = undef,
  $cert_cnf_path = undef,
  $csr_path      = undef,

  $privkey_owner = $::letsencrypt::params::letsencrypt_privkey_owner,
  $privkey_group = $::letsencrypt::params::letsencrypt_privkey_group,
  $privkey_mode  = $::letsencrypt::params::letsencrypt_privkey_mode,

  $cert_cnf_owner = $::letsencrypt::params::letsencrypt_cert_cnf_owner,
  $cert_cnf_group = $::letsencrypt::params::letsencrypt_cert_cnf_group,
  $cert_cnf_mode  = $::letsencrypt::params::letsencrypt_cert_cnf_mode,

  $csr_owner = $::letsencrypt::params::letsencrypt_csr_owner,
  $csr_group = $::letsencrypt::params::letsencrypt_csr_group,
  $csr_mode  = $::letsencrypt::params::letsencrypt_csr_mode,

  $false = $::letsencrypt::params::false,
  $test  = $::letsencrypt::params::test,
)
{
  $_privkey_path  = pick($privkey_path, "${dir}/${privkey}")
  $_cert_cnf_path = pick($cert_cnf_path, "${dir}/${cert_cnf}")
  $_csr_path      = pick($csr_path, "${dir}/${csr}")

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
  { $_privkey_path:
    ensure => $ensure,
  }

  exec
  { "::letsencrypt::cert::csr::assert::ssl_pkey::${servername}":
    command => "${false}",
    unless  => "${test} -f '$_privkey_path'",
  }

  file
  { $_privkey_path:
    ensure    => $file_ensure,
    show_diff => false,
    owner     => $privkey_owner,
    group     => $privkey_group,
    mode      => $privkey_mode,
  }

  # Generate OpenSSL configuration for CSR.
  file
  { $_cert_cnf_path:
    ensure  => $file_ensure,
    content => template('letsencrypt/cert.cnf.erb'),
    owner   => $cert_cnf_owner,
    group   => $cert_cnf_group,
    mode    => $cert_cnf_mode,
  }

  # Generate CSR.
  x509_request
  { $_csr_path:
    ensure      => $ensure,
    template    => $_cert_cnf_path,
    private_key => $_privkey_path,
    force       => true,
  }

  exec
  { "::letsencrypt::cert::csr::assert::x509_request::${servername}":
    command => "${false}",
    unless  => "${test} -f '$_csr_path'",
  }

  file
  { $_csr_path:
    ensure => $file_ensure,
    owner  => $csr_owner,
    group  => $csr_group,
    mode   => $csr_mode,
  }

  Ssl_pkey[$_privkey_path] -> Exec["::letsencrypt::cert::csr::assert::ssl_pkey::${servername}"] -> File[$_privkey_path]

  File[$_privkey_path]   -> X509_request[$_csr_path]
  File[$_cert_cnf_path] -> X509_request[$_csr_path]

  X509_request[$_csr_path] -> Exec["::letsencrypt::cert::csr::assert::x509_request::${servername}"] -> File[$_csr_path]
}
