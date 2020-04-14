install_data(
  [
    join_paths('data', 'icons' 'caffeine-cup-empty.svg'),
    join_paths('data', 'icons' 'caffeine-cup-full.svg')
  ],
  install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '@0@x@0@'.format('24'), 'status')
)

install_data(
  app_id + '.gschema.xml',
  install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)
