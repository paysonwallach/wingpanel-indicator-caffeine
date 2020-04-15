foreach i : ['24', '48']
  install_data(
    [
      join_paths('icons', 'caffeine-cup-empty.svg'),
      join_paths('icons', 'caffeine-cup-full.svg')
    ],
    install_dir: join_paths(
      get_option('datadir'), 'icons', 'hicolor', '@0@x@0@'.format(i), 'status'
    )
  )
endforeach

install_data(
  app_id + '.gschema.xml',
  install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)
