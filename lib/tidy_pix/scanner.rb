require 'tidy_pix/logging'
require 'find'

module TidyPix
  class Scanner
    include Logging

    def initialize
      @collector = Collector.instance
    end

    def scan(root_path)
      Find.find(root_path) do |path|
        file = Photo::StatFile.new(path)
        logger.info("testing: #{path}")

        next if FileTest.directory?(path)
        next unless jpeg?(file)
        next unless larger_than?(file, 600,400)
        next if md5_exists?(file)
        next if perceptual_match?(file, Phashion::Image::DEFAULT_DUPE_THRESHOLD)

        yield(file, @collector)
      end
    end

    def jpeg?(file)
      logger.info("mimetype: #{file.mime}")
      file.mime == 'image/jpeg'
    end

    def larger_than?(file, width, height)
      logger.info("filesize: #{file.width}x#{file.height}")
      (file.width * file.height) > (width * height)
    end

    def md5_exists?(file)
      file = @collector.find_by(md5: file.md5)
      if file
        logger.info("md5: hit")
        true
      else
        logger.info("md5: miss")
        false
      end
    end

    def perceptual_match?(file, threshold)
      distance = @collector.hamming_distances_from(file)
      logger.info("hamming: #{distance}")

      return false if distance.nil?

      distance < threshold
    end
  end
end
