# == Class: znapzend::service
#
class znapzend::service {

  # define service
  service { 'znapzend':
    enable    => $::znapzend::service_enable,
    ensure    => $::znapzend::service_ensure,
    hasstatus => $::znapzend::service_hasstatus,
    name      => $::znapzend::service_name,
  }

}
