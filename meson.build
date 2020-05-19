project('wingpanel-indicator-caffeine',
        'vala',
        'c',
        version : '0.1.0'
)

app_id = 'com.paysonwallach.caffeine'
app_name = 'Caffeine'

i18n = import('i18n')

add_project_arguments(['-DGETTEXT_PACKAGE="'+meson.project_name()+'"',
                       '-w'
                      ],
                      language:'c'
)

prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))
pkgdatadir = join_paths(prefix, get_option('datadir'), app_id)

conf_data = configuration_data()
conf_data.set_quoted('APP_ID', app_id)
conf_data.set_quoted('APP_NAME', app_name)
conf_data.set_quoted('PKGDATADIR', pkgdatadir)
config_header = configure_file(
  input : 'config.vala.in',
  output : 'config.vala',
  configuration : conf_data
)

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language: 'c')

granite_dep = dependency('granite')
json_dep = dependency('json-glib-1.0')
libnotify_dep = dependency('libnotify')
libwingpanel_dep = dependency('wingpanel-2.0')
indicators_dir = libwingpanel_dep.get_pkgconfig_variable('indicatorsdir',
  define_variable: [
    'libdir',
    libdir
  ]
)

shared_module(meson.project_name(),
              'src/Indicator.vala',
              'src/MenuButton.vala',
              'src/CancellableTimeout.vala',
              'src/Countdown.vala',
              'src/CountdownTimerController.vala',
              'src/Duration.vala',
              'src/Utils.vala',
              dependencies: [
                granite_dep,
                libnotify_dep,
                libwingpanel_dep
              ],
              install: true,
              install_dir: indicators_dir
  config_header,
    json_dep,
)

subdir('data')
