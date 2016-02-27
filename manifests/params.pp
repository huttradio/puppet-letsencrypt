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
  # Package configuration options.
  $package_repo_provider = 'git'
  $package_repo_source   = 'https://github.com/lukas2511/letsencrypt.sh.git'
  $package_repo_revision = 'master'

  # Apache configuration options.
  $apache_vhost      = $::fqdn
  $apache_vhost_ip   = '*'
  $apache_vhost_port = '80'

  if ($::osfamily == 'RedHat' or $::operatingsystem =~ /^[Aa]mazon$/)
  {
    $apache_group = 'apache'
  }
  elsif ($::osfamily == 'Debian')
  {
    $apache_group = 'www-data'
  }
  elsif ($::osfamily == 'FreeBSD')
  {
    $apache_group = 'www'
  }
  elsif ($::osfamily == 'Gentoo')
  {
    $apache_group = 'apache'
  }
  elsif ($::osfamily == 'Suse')
  {
    $apache_group = 'wwwrun'
  }

  # Cron configuration options.
  $cron_user = 'root'

  # Let's Encrypt configuration options.
  $letsencrypt_dir       = '/opt/letsencrypt'
  $letsencrypt_dir_owner = 'puppet'
  $letsencrypt_dir_group = $apache_group
  $letsencrypt_dir_mode  = '0750'

  $letsencrypt_sh        = 'letsencrypt-sh'
  $letsencrypt_sh_source = 'puppet:///modules/letsencrypt/letsencrypt-sh'
  $letsencrypt_sh_owner  = 'root'
  $letsencrypt_sh_group  = 'root'
  $letsencrypt_sh_mode   = '0555'

  $letsencrypt_cert_dir_base  = '/etc/letsencrypt/live'
  $letsencrypt_cert           = 'cert.pem'
  $letsencrypt_chain          = 'chain.pem'
  $letsencrypt_fullchain      = 'fullchain.pem'
  $letsencrypt_privkey        = 'privkey.pem'

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
