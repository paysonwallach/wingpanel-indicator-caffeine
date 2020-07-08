project(
  'wingpanel-indicator-caffeine',
  'vala',
  'c',
  version : '0.1.0'
)

app_id = 'com.paysonwallach.caffeine'
app_name = 'Caffeine'

i18n = import('i18n')
vala = meson.get_compiler('vala')

po_dir = join_paths(meson.current_source_dir(), 'po')
vapi_dir = join_paths(meson.source_root(), 'vapi')

add_project_arguments(
  [
    '-DGETTEXT_PACKAGE="' + meson.project_name() + '"',
    '-w'
  ],
  language:'c'
)

prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))
datadir = join_paths(prefix, get_option('datadir'))
pkglibdir = join_paths(libdir, app_id)
pkgdatadir = join_paths(datadir, app_id)
pkgpluginslibdir = join_paths(pkglibdir, 'plugins')
pkgpluginsdatadir = join_paths(pkgdatadir, 'plugins')

conf_data = configuration_data()
conf_data.set_quoted('APP_ID', app_id)
conf_data.set_quoted('APP_NAME', app_name)
conf_data.set_quoted('PKGDATA_DIR', pkgdatadir)
conf_data.set_quoted('PKGPLUGINS_LIB_DIR', pkgpluginslibdir)
conf_data.set_quoted('PKGPLUGINS_DATA_DIR', pkgpluginsdatadir)
conf_data.set_quoted('DATA_VERSION', '0')

config_h = configure_file(
  output: 'config.h',
  configuration: conf_data
)

config_dep = declare_dependency(
  dependencies: vala.find_library('config', dirs: vapi_dir),
  sources: config_h
)

add_global_arguments(
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
  language: 'c'
)

granite_dep = dependency('granite')
glib_json_dep = dependency('json-glib-1.0')
libnotify_dep = dependency('libnotify')
libpeas_dep = dependency('libpeas-1.0', version: '>=1.1.0')
libpeas_gtk_dep = dependency('libpeas-gtk-1.0', version: '>=1.1.0')
libwingpanel_dep = dependency('wingpanel-2.0')
indicators_dir = libwingpanel_dep.get_pkgconfig_variable(
  'indicatorsdir',
  define_variable : [
    'libdir',
    libdir
  ]
)

shared_module(
  meson.project_name(),
  'src/Indicator.vala',
  'src/MenuButton.vala',
  'src/CancellableTimeout.vala',
  'src/Countdown.vala',
  'src/CountdownTimerController.vala',
  'src/Duration.vala',
  'src/Utils.vala',
  dependencies: [
    config_dep,
    granite_dep,
    glib_json_dep,
    libnotify_dep,
    libwingpanel_dep,
    libpeas_dep,
    libpeas_gtk_dep,
  ],
  install: true,
  install_dir: indicators_dir
)

subdir('data')
subdir('plugins')

meson.add_install_script('meson/post_install.py')
