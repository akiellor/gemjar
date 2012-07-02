require 'rubygems'
require 'fpm'

class FPM::Package::Dir < FPM::Package
  def copy(source, destination)
    directory = File.dirname(destination)
    if !File.directory?(directory)
      FileUtils.mkdir_p(directory)
    end

    # Create a directory if this path is a directory
    if File.directory?(source) and !File.symlink?(source)
      @logger.debug("Creating", :directory => destination)
      if !File.directory?(destination)
        FileUtils.mkdir(destination)
      end
    else
      # Otherwise try copying the file.
      begin
        @logger.debug("Linking", :source => source, :destination => destination)
        File.link(source, destination)
      rescue Errno::EXDEV, Errno::EEXIST
        # Hardlink attempt failed, copy it instead
        @logger.debug("Copying", :source => source, :destination => destination)
        FileUtils.copy_entry(source, destination)
      end
    end

    copy_metadata(source, destination)
  end # def copy
end