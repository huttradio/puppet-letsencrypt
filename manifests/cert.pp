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
  $environment_staging = false,
  $package_manage      = true,
  $directories_manage  = true,
  $apache_manage       = true,

  $ensure = 'present',

  $servername = $name,

  $environment = undef,

  $letsencrypt_csrs_dir       = undef,
  $letsencrypt_csrs_dir_base  = $::letsencrypt::params::letsencrypt_csrs_dir_base,
  $letsencrypt_csrs_dir_owner = $::letsencrypt::params::letsencrypt_csrs_dir_owner,
  $letsencrypt_csrs_dir_group = $::letsencrypt::params::letsencrypt_csrs_dir_group,
  $letsencrypt_csrs_dir_mode  = $::letsencrypt::params::letsencrypt_csrs_dir_mode,

  $letsencrypt_csr_path = undef,
  $letsencrypt_csr      = $::letsencrypt::params::letsencrypt_csr,
)
{
  $_letsencrypt_csrs_dir  = pick($letsencrypt_csrs_dir, "${letsencrypt_csrs_dir_base}/${servername}")
  $_letsencrypt_csr_path  = pick($letsencrypt_csr_path, "${_letsencrypt_csrs_dir}/${letsencrypt_csr}")

  if ($environment_staging)
  {
    $_environment = pick($environment, $::letsencrypt::params::environment_staging)
  }
  else
  {
    $_environment = pick($environment, $::letsencrypt::params::environment_production)
  }

  validate_re($ensure, ['^present$', '^absent$'], 'ensure can only be one of present or absent')
  validate_re($email, '^[A-Za-z0-9][A-Za-z0-9_\.]*[A-Za-z0-9]@[A-Za-z0-9][0-9A-Za-z\-]*[A-Za-z0-9]\.[A-Za-z0-9][0-9A-Za-z\-\.]*[A-Za-z0-9]$', "${email} does not appear to be a valid email address")

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

  # Generate the private key and CSR.
  ::letsencrypt::cert::csr
  { $servername:
    ensure => $ensure,
    email  => $email,
    dir    => $_letsencrypt_csrs_dir,
  }

  # Install the signed certificates and the private key.
  ::letsencrypt::cert::generate
  { $servername:
    ensure               => $ensure,
    environment          => $_environment,
    email                => $email,
    letsencrypt_csr_path => $_letsencrypt_csr_path,
  }

  File[$_letsencrypt_csrs_dir] -> ::Letsencrypt::Cert::Csr[$servername] ~> ::Letsencrypt::Cert::Generate[$servername]

  if ($package_manage and $ensure == 'present')
  {
    Class['::letsencrypt::package'] -> ::Letsencrypt::Cert::Generate[$servername]
  }

  if ($directories_manage and $ensure == 'present')
  {
    Class['::letsencrypt::directories'] -> ::Letsencrypt::Cert::Generate[$servername]
  }

  if ($apache_manage and $ensure == 'present')
  {
    Class['::letsencrypt::apache'] -> ::Letsencrypt::Cert::Generate[$servername]
  }
}
