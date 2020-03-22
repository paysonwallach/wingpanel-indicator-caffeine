project('wingpanel-indicator-caffeine', 'vala', 'c', version: '0.1.0')

i18n = import('i18n')

prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))

app_id = 'com.paysonwallach.caffeine'

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language: 'c')

libwingpanel_dep = dependency('wingpanel-2.0')
indicators_dir = libwingpanel_dep.get_pkgconfig_variable('indicatorsdir', define_variable: ['libdir', libdir])

shared_module(meson.project_name(),
              'src/Indicator.vala',
              dependencies: libwingpanel_dep,
              install: true,
              install_dir: indicators_dir
)

subdir('data')
