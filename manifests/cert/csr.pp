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
  $cert_cnf_dir,
  $cert_path,
  $csr_path,
  $privkey_path,

  $ensure = 'present',

  $servername = $name,

  $cert_cnf = $::letsencrupt::params::letsencrypt_cert_cnf,

  $cert_cnf_path = undef,

  $cert_cnf_source = $::letsencrypt::params::letsencrypt_cert_cnf_source,
  $cert_cnf_owner  = $::letsencrypt::params::letsencrypt_cert_cnf_owner,
  $cert_cnf_group  = $::letsencrypt::params::letsencrypt_cert_cnf_group,
  $cert_cnf_mode   = $::letsencrypt::params::letsencrypt_cert_cnf_mode,

  $cron_manage  = true,
  $cron_command = undef,
  $cron_user    = undef,
)
{
  $_openssl_cert_cnf_path = pick($openssl_cert_cnf_path, "${letsencrypt_dir}/cert.cnf")

  if ($ensure == 'present')
  {
    $file_ensure = 'file'
  }
  else
  {
    $file_ensure = $ensure
  }

  # Certificate, CSR and private key.
  ssl_pkey
  { $privkey_path:
    ensure => $ensure,
  }

  x509_cert
  { $cert_path:
    ensure => $ensure,
  }

  x509_request
  { $csr_path:
    ensure      => $ensure,
    commonname  => $servername,
    template    => $_openssl_cert_cnf_path,
    private_key => $privkey_path,
  }

  # Manage files in Puppet.
  file
  { $_openssl_cert_cnf_path:
    ensure => $file_ensure,
    source => $openssl_cert_cnf_source,
    owner  => $openssl_cert_cnf_owner,
    group  => $openssl_cert_cnf_group,
    mode   => $openssl_cert_cnf_mode,
  }

  File["${letsencrypt_dir}/cert.cnf"] -> X509_request[$csr_path]
  Sssl_pkay[$privkey_path] ~> X509_cert[$cert_path] ~> X509_request[$csr_path]
}
