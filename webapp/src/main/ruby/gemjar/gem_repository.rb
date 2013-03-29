require 'fileutils'
require 'rubygems/specification'
require 'rubygems/dependency_installer'
require 'gemjar/gem_log'

module Gemjar
  class GemRepository
    def install name, version
      ::Gem.configuration.verbose = true
      ::Gem::DefaultUserInteraction.ui = Gemjar::GemLog.new

      tmpdir = Dir.mktmpdir
      installer = ::Gem::DependencyInstaller.new :install_dir => "#{tmpdir}/gem_home", :ignore_dependencies => true
      installer.install name, version
      Gem.new "#{tmpdir}/gem_home", name, version
    end
  end
end