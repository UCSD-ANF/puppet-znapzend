# == Class: znapzend::install
#
class znapzend::install {
  if $znapzend::package_manage {
    package { $znapzend::package_name :
      ensure => $znapzend::package_ensure,
    }
  }
}
