# == Class: znapzend::service
#
class znapzend::service {

  # define service
  service { $::znapzend::service_name:
    enable    => $::znapzend::service_enable,
    ensure    => $::znapzend::service_ensure,
    hasstatus => $::znapzend::service_hasstatus,
    name      => $::znapzend::service_name,
  }

}
