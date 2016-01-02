require 'singleton'
require 'sequel'
require 'phashion'
require 'fileutils'

module TheseDamnPhotos
  class Collector
    include Singleton

    def self.storage_root=(path)
      @@storage_root = path
    end

    def storage_root
      @@storage_root or abort('the `storage_path` must be set before instantiating a Collector')
    end

    ##
    # returns a valid pathname
    #
    def storage_path(file)
      path = File.join(storge_root, file.filename)
      if File.exist?(path)
      end
    end

    def initialize
      @files = Dir.glob(File.join(storage_root, '**', '*'))
    end

    def database
      return @database if defined?(@database)

      database_file = File.join(storage_root, 'photos.sqlite3')
      @database = Sequel.sqlite(database_file)
      unless File.exist?(database_file)
        Photo.create_schema!(@database)
      end

      @database.synchronize do |c|
        c.enable_load_extension(true)
        c.load_extension(Phashion.so_file)
      end

      @database
    end

    ##
    # syncs the directory cache with the db. the cache is the canonical source
    # * any files that exist in the cache, but on in the db will be added,
    # * any files missing from the cache will be deleted form the db
    #  this method sucks, but i can't think of a better way to do this
    def sync!
    end

    def insert(file)
      database[:photos].insert(
        md5: file.md5,
        phash1: file.phash1,
        phash2: file.phash2,
        size: file.size,
        original_path: file.path,
        filename: file.filename,
        mime: file.mime,
        exif: Sequel.blob(Marshal.dump(file.exif.to_hash))
      )
    end

    def copy_to_dest(file)
      FileUtils.cp(file.path, storage_path(file))
    end

    def save(file)
      insert(file) && copy_to_dest(file)
    end

    def find_by(conditions = {})
      database[:photos].where(conditions).first
    end

    #sqlite cannot store unsigned 64bit ints, so we must come up with this hack:
    def hamming_distances_from(file)
      dataset = database['select id, hamming_distance(phash1, phash2, ?, ?) from photos', file.phash1, file.phash2]
      if dataset.all.empty?
        nil
      else
        0
      end
    end
  end
end
