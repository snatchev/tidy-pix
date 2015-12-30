

brew install libmagic


this seems the only way to ensure our native ext. has the right stuff enabled
`gem uninstall sqlite3`
`gem install sqlite3 --verbose -- --with-sqlite3-include=/usr/local/opt/sqlite/include --with-sqlite3-lib=/usr/local/opt/sqlite/lib`

