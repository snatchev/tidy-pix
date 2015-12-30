require 'find'
require 'exifr'
require 'filemagic'

module TheseDamnPhotos
  class Scanner

    MIME = FileMagic.open(:mime)

    class File
      def initialize(path)
        @path = path
      end

      def mime
        @mime = MIME.file(@path, true)
      end

      def size
        File.size(@path)
      end

      def md5
        Digest::MD5.file(@path).hexdigest
      end

      def phash
        @phash ||= Phashion.image_hash_for(@path)
      end

      def exif
        @exif ||= EXIFR::JPEG.new(@path)
      end

      def width
        exif.width
      end

      def height
        exif.height
      end

    end

    def initialize
      @collector = Collector.instance
    end

    def scan(root_path)
      Find.find(root_path) do |path|
        file = File.new(path)

        next if FileTest.directory?(path)
        next unless jpeg?(file)
        next unless larger_than?(file, 600,400)
        next if md5_exists?(file)
        next if hamming_distance_greater_than?(file, 0.9)

        @collector << path
      end
    end

    def jpeg?(file)
      file.mime == 'image/jpeg'
    end

    def larger_than?(file, width, height)
      (file.width * file.height) > (width * height)
    end

    def md5_exists?(file)
      @collector.find_by(md5: file.md5)
    end

    def hamming_distance_greater_than?(file, distance)
      @collector.hamming_distances_from(file.phash) > distance
    end
  end
end
