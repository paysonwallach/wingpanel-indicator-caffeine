shared_library('xscreensaver',
  [
    'Main.vala'
  ],
  dependencies: [
    libpeas_dep
  ],
  install: true,
  install_dir: join_paths(pkgpluginslibdir, 'xscreensaver'),
)

i18n.merge_file(
  type: 'desktop',
  input: 'xscreensaver.plugin.in',
  output: 'xscreensaver.plugin',
  po_dir: po_dir,
  install: true,
  install_dir: join_paths(pkgpluginslibdir, 'xscreensaver')
)
