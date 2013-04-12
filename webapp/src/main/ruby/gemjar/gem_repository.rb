require 'fileutils'
require 'rubygems/specification'
require 'rubygems/dependency_installer'
require 'gemjar/gem_log'
require 'net/http'

module Gemjar
  class GemRepository
    def install name, version
      ::Gem.configuration.verbose = :loud
      ::Gem::DefaultUserInteraction.ui = Gemjar::GemLog.new

      tmpdir = Dir.mktmpdir

      gemfile_path = File.join(tmpdir, "gem")

      download "http://rubygems.org/gems/#{name}-#{version}.gem", gemfile_path

      installer = ::Gem::DependencyInstaller.new :env_shebang => true, :install_dir => "#{tmpdir}/gem_home", :ignore_dependencies => true, :force => true, :domain => :local
      installer.install gemfile_path
      Gem.new "#{tmpdir}/gem_home", name, version
    end

    def download uri, path, attempts = 10
      raise "Max Redirects (10) exceeded" if attempts == 0

      uri = URI.parse(uri)

      http = Net::HTTP.start(uri.host, uri.port)

      http.request_get(uri.path) do |resp|
        if resp.code.to_i == 302
          return download resp['location'], path, attempts - 1
        end

        f = File.open(path, "w+")
        begin
          resp.read_body do |segment|
            f.write(segment)
          end
        ensure
          f.close()
        end
      end
    end
  end
end
