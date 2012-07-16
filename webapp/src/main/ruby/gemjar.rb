module Gemjar
  WORKDIR = "#{Dir.tmpdir}/gemjars" and FileUtils.mkdir_p(WORKDIR)
end

require 'gemjar/app'
require 'gemjar/artifact'
require 'gemjar/artifact_builder'
require 'gemjar/dependency'
require 'gemjar/gem'
require 'gemjar/logger'
require 'gemjar/version'
