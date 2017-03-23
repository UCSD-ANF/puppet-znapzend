# == Class: znapzend::plans
#
class znapzend::plans () { include ::znapzend
   create_resources ('znapzend::config', $::znapzend::plans)
}
