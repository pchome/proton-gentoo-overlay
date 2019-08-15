project('steam-helper', ['cpp'], version : '4.11', meson_version : '>= 0.49')

sdk_ver = '142'

src_path = meson.source_root() / 'steam_helper'

# wchar & tm
inc = include_directories([
  '/usr/include/wine/msvcrt/',
  './lsteamclient/steamworks_sdk_' + sdk_ver,
])

dep = declare_dependency(link_args: [
  '-L'+src_path,
  '-lsteam_api'
])

executable('steam.exe.so', files(src_path / 'steam.cpp'),
  dependencies        : dep,
  include_directories : inc,
  install             : true)
