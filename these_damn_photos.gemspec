lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'these_damn_photos/version'

Gem::Specification.new do |s|
  s.name          = 'these_damn_photos'
  s.version       = TheseDamnPhotos::VERSION
  s.authors       = ['Stefan Natchev']
  s.email         = ['stefan.natchev@gmail.com']
  s.description   = 'Scans and de-dupes photos, finally getting all your backups in order'
  s.homepage      = ''
  s.files         = `git ls-files`.split("\n")
  s.rdoc_options  = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.summary       = %q{}
  s.test_files    = `git ls-files test`.split("\n")

  s.add_dependency 'phashion', '~> 1.1.1'
  s.add_dependency 'exifr', '~> 1.2.3'
  s.add_dependency 'sequel', '~> 4.29.0'
  s.add_dependency 'sqlite3', '~> 1.3.11'
  s.add_dependency 'thor'
  s.add_dependency 'ruby-filemagic', '~> 0.7.1'
  s.add_development_dependency 'minitest', '~> 5.2.2'
  s.add_development_dependency 'pry'
end
