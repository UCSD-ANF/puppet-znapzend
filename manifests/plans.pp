# == Class: znapzend::plans
#
class znapzend::plans () {
  include znapzend

  $znapzend::plans.each |String $plan_name, Hash $plan_config| {
    znapzend::config { $plan_name:
      * => $plan_config,
    }
  }
}
