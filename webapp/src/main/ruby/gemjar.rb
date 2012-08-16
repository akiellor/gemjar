module Gemjar
  WORK_DIRECTORY = "#{Dir.tmpdir}/gemjars" and FileUtils.mkdir_p(WORK_DIRECTORY)
end

require 'gemjar/app'
require 'gemjar/artifact'
require 'gemjar/artifact_builder'
require 'gemjar/dependency'
require 'gemjar/gem'
require 'gemjar/logger'
