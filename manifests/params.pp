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
  # Commands.
  $false = '/bin/false'
  $test  = '/usr/bin/test'

  # Package configuration options.
  $package_provider = 'git'
  $package_source   = 'https://github.com/lukas2511/letsencrypt.sh.git'
  $package_revision = 'master'

  $package_dir        = '/opt/letsencrypt'
  $package_dir_owner  = 'root'
  $package_dir_group  = 'root'

  # Virtual host configuration options.
  $vhost      = $::fqdn
  $vhost_port = '8133'

  $vhost_dir       = "${letsencrypt_dir_base}/vhost"
  $vhost_dir_owner = 'root'
  $vhost_dir_group = 'root'
  $vhost_dir_mode  = '0555'

  # Base directory locations and permissions.
  $letsencrypt_dir_base  = '/etc/letsencrypt'
  $letsencrypt_dir_owner = 'root'
  $letsencrypt_dir_group = 'root'
  $letsencrypt_dir_mode  = '0555'

  $letsencrypt_csrs_dir_base  = "${letsencrypt_dir_base}/csrs"
  $letsencrypt_csrs_dir_owner = 'root'
  $letsencrypt_csrs_dir_group = 'root'
  $letsencrypt_csrs_dir_mode  = '0550'

  $letsencrypt_certs_dir_base  = "${letsencrypt_dir_base}/certs"
  $letsencrypt_certs_dir_owner = 'root'
  $letsencrypt_certs_dir_group = 'root'
  $letsencrypt_certs_dir_mode  = '0550'

  $letsencrypt_scripts_dir_base   = "${letsencrypt_dir_base}/scripts"
  $letsencrypt_scripts_dir_owner  = 'root'
  $letsencrypt_scripts_dir_group  = 'root'
  $letsencrypt_scripts_dir_mode   = '0555'

  # letsencrypt.sh wrapper script.
  $letsencrypt_script          = 'letsencrypt-sh'
  $letsencrypt_script_template = 'letsencrypt/letsencrypt-sh.erb'
  $letsencrypt_script_owner    = 'root'
  $letsencrypt_script_group    = 'root'
  $letsencrypt_script_mode     = '0555'

  # Certificates and key file names and permissions.
  $letsencrypt_cert_cnf       = 'cert.cnf'
  $letsencrypt_cert_cnf_owner = 'root'
  $letsencrypt_cert_cnf_group = 'root'
  $letsencrypt_cert_cnf_mode  = '0444'

  $letsencrypt_csr       = 'cert.csr'
  $letsencrypt_csr_owner = 'root'
  $letsencrypt_csr_group = 'root'
  $letsencrypt_csr_mode  = '0444'

  $letsencrypt_cert       = 'cert.pem'
  $letsencrypt_chain      = 'chain.pem'
  $letsencrypt_fullchain  = 'fullchain.pem'
  $letsencrypt_cert_owner = 'root'
  $letsencrypt_cert_group = 'root'
  $letsencrypt_cert_mode  = '0444'

  $letsencrypt_privkey       = 'privkey.pem'
  $letsencrypt_privkey_owner = 'root'
  $letsencrypt_privkey_group = 'root'
  $letsencrypt_privkey_mode  = '0400'

  # Let's Encrypt environment locations.
  $environment_staging    = 'https://acme-staging.api.letsencrypt.org/directory'
  $environment_production = 'https://acme-v01.api.letsencrypt.org/directory'
}
