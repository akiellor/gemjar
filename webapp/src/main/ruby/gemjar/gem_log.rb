module Gemjar
  class GemLog
    DEFAULT_LOGGER = Java::OrgSlf4j::LoggerFactory.get_logger("GemLog")

    def initialize logger = DEFAULT_LOGGER
      @logger = logger
    end

    def say message
      @logger.info message
    end

    def alert message
      @logger.info message
    end

    def alert_error message
      @logger.error message
    end

    def alert_warning message
      @logger.warn message
    end

    def download_reporter
      UserInteractionDownloadReporter.new(self)
    end
  end

  class UserInteractionDownloadReporter
    def initialize(ui)
      @ui = ui
    end

    def fetch(file_name, total_bytes)
      @ui.say "Fetching: #{file_name} (#{total_bytes / 1024} KB)"
    end

    def update(bytes)
    end

    def done
      @ui.say "Done"
    end
  end
end