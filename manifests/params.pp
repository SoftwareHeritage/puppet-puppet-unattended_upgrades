#
class unattended_upgrades::params {
  if $facts['os']['family'] != 'Debian' {
    fail('This module only works on Debian or derivatives like Ubuntu')
  }

  $default_auto                 = { 'fix_interrupted_dpkg' => true, 'remove' => true, 'reboot' => false, 'clean' => 0, 'reboot_time' => 'now', }
  $default_mail                 = { 'only_on_error'        => true, }
  $default_backup               = { 'archive_interval'     => 0, 'level'     => 3, }
  $default_age                  = { 'min'                  => 2, 'max'       => 0, }
  $default_upgradeable_packages = { 'download_only'        => 0, 'debdelta'  => 1, }
  # those are DEPRECATED and will be removed in a future releaseq
  $default_options              = {
    'force_confdef'        => false,
    'force_confold'        => false,
    'force_confnew'        => false,
    'force_confmiss'       => false,
  }

  case fact('lsbdistid') {
    'debian', 'raspbian': {
      case fact('lsbdistcodename') {
        'bullseye': {
          $origins            = [
            'origin=Debian,codename=${distro_codename},label=Debian', #lint:ignore:single_quote_string_with_variables
            'origin=Debian,codename=${distro_codename}-security,label=Debian-Security', #lint:ignore:single_quote_string_with_variables
          ]
        }
        default: {
          $origins            = [
            'origin=Debian,codename=${distro_codename},label=Debian', #lint:ignore:single_quote_string_with_variables
            'origin=Debian,codename=${distro_codename},label=Debian-Security', #lint:ignore:single_quote_string_with_variables
          ]
        }
      }
    }
    'ubuntu', 'neon': {
      # Ubuntu: https://ubuntu.com/about/release-cycle and https://wiki.ubuntu.com/Releases
      # Ubuntu 18.04 and up do allow the use of Origins-Pattern; 16.04 is out of support for Vox Pupuli.
      $origins            = [
        'origin=${distro_id},suite=${distro_codename}', #lint:ignore:single_quote_string_with_variables
        'origin=${distro_id},suite=${distro_codename}-security', #lint:ignore:single_quote_string_with_variables
        'origin=${distro_id}ESMApps,suite=${distro_codename}-apps-security', #lint:ignore:single_quote_string_with_variables
        'origin=${distro_id}ESM,suite=${distro_codename}-infra-security', #lint:ignore:single_quote_string_with_variables
      ]
    }
    'LinuxMint': {
      case fact('lsbmajdistrelease') {
        # Linux Mint 18* is based on Ubuntu 16.04
        default: {
          $origins            = [
            '${distro_id}:${distro_codename}-security', #lint:ignore:single_quote_string_with_variables
          ]
        }
      }
    }
    default: {
      $origins       = undef
    }
  }
}
