# == Class: znapzend::service
#
class znapzend::service {
  # define service
  service { $znapzend::service_name:
    ensure    => $znapzend::service_ensure,
    enable    => $znapzend::service_enable,
    hasstatus => $znapzend::service_hasstatus,
    name      => $znapzend::service_name,
  }
}
