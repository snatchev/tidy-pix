require 'logger'

module TidyPix
  module Logging
    def self.logger
      return @logger if defined?(@logger)

      @logger = Logger.new(STDOUT)
      @logger.datetime_format = ''

      @logger
    end

    def logger
      TidyPix::Logging.logger
    end
  end
end
