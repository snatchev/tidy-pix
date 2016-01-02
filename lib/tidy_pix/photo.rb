require 'exifr'
require 'filemagic'

module TidyPix
  class Photo

    MIME = FileMagic.open(:mime)

    class StatFile
      attr_reader :path

      #a lazy, memoized struct for testing a photo's contents
      def initialize(path)
        @path = path
      end

      def filename
        File.basename(path)
      end

      def mime
        @mime ||= MIME.file(@path, true)
      end

      def size
        @size ||= File.size(@path)
      end

      def md5
        @md5 ||= Digest::MD5.file(@path).hexdigest
      end

      def phash
        @phash ||= Phashion.image_hash_for(@path)
      end

      #the first 32 bits of a 64bit int
      def phash1
        (phash >> 32) & 0xFFFFFFFF
      end

      #the last 32 bits of s 64bit int
      def phash2
        phash & 0xFFFFFFFF
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

    def self.create_schema!(database)
      database.run <<-SQL
        CREATE TABLE schemas (
          version INT DEFAULT 0,
          created_at TEXT
        );

        INSERT INTO schemas VALUES (0, '#{Time.now}');

        CREATE TABLE photos (
          id      INT PRIMARY KEY ASC,
          md5     CHAR(32) UNIQUE NOT NULL,
          phash1  INT,
          phash2  INT,
          size    INT,
          exif    BLOB,
          mime    TEXT,
          filename      TEXT,
          original_path TEXT
        );

        CREATE INDEX photos_md5 ON photos(md5);
        CREATE INDEX photos_phash ON photos(phash1, phash2);
      SQL
    end

    def initialize(path)
      @path = path
    end
  end
end
