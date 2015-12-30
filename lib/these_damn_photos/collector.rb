require 'singleton'
require 'sequel'

module TheseDamnPhotos
  class Collector
    include Singleton

    def self.storage_root=(path)
      @@storage_root = path
    end

    def storage_root
      @@storage_root
    end

    def initialize
      @database = Sequel.sqlite(File.join(storage_root, 'photos.sqlite3'))
      @database.synchronize do |c|
        c.enable_load_extension(true)
        c.load_extension(Phashion.so_file)
      end

      @files = Dir.glob(File.join(storage_root, '**', '*'))
    end

    def <<(file)
    end

    def find_by(conditions = {})
      @database[:photos].where(conditions).first
    end

    #sqlite cannot store unsigned 64bit ints, so we must come up with this hack:
    def hamming_distances_from(phash)
      upper = (phash >> 32) & 0xFFFFFFFF
      lower = phash & 0xFFFFFFFF
      @database['select id, hamming_distance(phash1, phash2, ?, ?) from photos', upper, lower]
    end
  end
end
