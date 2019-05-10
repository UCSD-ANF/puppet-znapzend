# == Class: znapzend::plans
#
class znapzend::plans {
  create_resources('znapzend::plan', $znapzend::plans)
}
