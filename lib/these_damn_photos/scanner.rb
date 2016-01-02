require 'find'

module TheseDamnPhotos
  class Scanner

    def initialize
      @collector = Collector.instance
    end

    def scan(root_path)
      Find.find(root_path) do |path|
        file = Photo::StatFile.new(path)

        puts path

        next if FileTest.directory?(path)
        next unless jpeg?(file)
        next unless larger_than?(file, 600,400)
        next if md5_exists?(file)
        next if hamming_distance_greater_than?(file, Phashion::Image::DEFAULT_DUPE_THRESHOLD)

        yield(file, @collector)
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

    def hamming_distance_greater_than?(file, threshold)
      distance = @collector.hamming_distances_from(file)
      return false if distance.nil?

      distance > threshold
    end
  end
end
