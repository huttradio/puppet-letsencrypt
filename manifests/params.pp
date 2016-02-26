# Class: letsencrypt::server
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
class letsencrypt::params
{
  # Fail on non-Debian distros. These should be supported in future, as Let's Encrypt's Apache
  # plugin matures.
  if ($::osfamily != 'Debian')
  {
    fail('only supported OS family is Debian')
  }

  # Package configuration options.
  $package_repo_path     = '/opt/letsencrypt'
  $package_repo_provider = 'git'
  $package_repo_source   = 'https://github.com/letsencrypt/letsencrypt.git'
  $package_repo_revision = 'v0.4.0'

  if ($::operatingsystem == 'Debian' and versioncmp($::operatingsystemrelease, '9') >= 0)
  {
    $package_source  = 'package'
    $package_package = 'letsencrypt'
  }
  elsif ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '16.04') >= 0)
  {
    $package_source  = 'package'
    $package_package = 'letsencrypt'
  }
  else
  {
    $package_source = 'vcsrepo'
  }

  # Apache configuration options.
  if ($::osfamily == 'Debian')
  {
    $apache_package = 'apache2'
  }

  # Cron configuration options.
  $cron_user = 'root'

  # Let's Encrypt configuration options.
  if ($::operatingsystem == 'Debian' and versioncmp($::operatingsystemrelease, '9') >= 0)
  {
    $letsencrypt         = 'letsencrypt'
    $letsencrypt_dir     = '/usr/bin'
  }
  elsif ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '16.04') >= 0)
  {
    $letsencrypt         = 'letsencrypt'
    $letsencrypt_dir     = '/usr/bin'
  }
  else
  {
    $letsencrypt         = 'letsencrypt-auto'
    $letsencrypt_dir     = '/opt/letsencrypt'
  }

  $letsencrypt_cert_dir_base  = '/etc/letsencrypt/live'
  $letsencrypt_cert       = 'cert.pem'
  $letsencrypt_chain     = 'chain.pem'
  $letsencrypt_fullchain = 'fullchain.pem'
  $letsencrypt_privkey   = 'privkey.pem'

  $letsencrypt_cert_dir_owner = 'root'
  $letsencrypt_cert_dir_group = 'root'
  $letsencrypt_cert_dir_mode  = '500'

  $letsencrypt_cert_owner = 'root'
  $letsencrypt_cert_group = 'root'
  $letsencrypt_cert_mode  = '444'

  $letsencrypt_privkey_owner = 'root'
  $letsencrypt_privkey_group = 'root'
  $letsencrypt_privkey_mode  = '400'
}
