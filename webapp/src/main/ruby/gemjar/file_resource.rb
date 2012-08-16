require 'digest/md5'
require 'digest/sha1'

module Gemjar
  class FileResource
    attr_reader :path

    def initialize path
      @path = path
    end

    def md5
      Digest::MD5.file(@path).to_s
    end

    def sha1
      Digest::SHA1.file(@path).to_s
    end

    def content
      File.read(@path)
    end
  end
end