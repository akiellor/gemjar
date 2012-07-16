require 'gemjar/artifact'
require 'sinatra/base'
require 'digest/md5'
require 'digest/sha1'

module Gemjar
  class App < Sinatra::Base
    before do
      expires (365 * 24 * 3600), :public
    end

    before('*.sha1') { content_type 'plain/text' }
    before('*.md5') { content_type 'plain/text' }
    before('*.xml') { content_type 'application/xml' }

    get "/ping" do
    end

    get "/jars/org.rubygems/:name-:version.jar" do |name, version|
      gem_jar = Artifact.ensure(name, version) or raise Sinatra::NotFound
      send_file gem_jar.jar, :filename => gem_jar.jar
    end

    get "/jars/org.rubygems/:name-:version.jar.sha1" do |name, version|
      gem_jar = Artifact.ensure(name, version) or raise Sinatra::NotFound
      body Digest::SHA1.file(gem_jar.jar).to_s
    end

    get "/jars/org.rubygems/:name-:version.jar.md5" do |name, version|
      gem_jar = Artifact.ensure(name, version) or raise Sinatra::NotFound
      body Digest::MD5.file(gem_jar.jar).to_s
    end

    get "/ivys/org.rubygems/ivy-:name-:version.xml" do |name, version|
      gem_jar = Artifact.ensure(name, version) or raise Sinatra::NotFound
      body File.read(gem_jar.ivy)
    end

    get "/ivys/org.rubygems/ivy-:name-:version.xml.sha1" do |name, version|
      gem_jar = Artifact.ensure(name, version) or raise Sinatra::NotFound
      body Digest::SHA1.file(gem_jar.ivy).to_s
    end

    get "/ivys/org.rubygems/ivy-:name-:version.xml.md5" do |name, version|
      gem_jar = Artifact.ensure(name, version) or raise Sinatra::NotFound
      body Digest::MD5.file(gem_jar.ivy).to_s
    end

    #support artifactory/gradle ivy default patterns
    get "/org.rubygems/:name/:version/*" do |name, version, rs|
      ext = rs.scan(/(\.jar.*|\.xml.*)/).last
      redirect "/jars/org.rubygems/#{name}-#{version}#{ext}" if rs =~ /jar/
      redirect "/ivys/org.rubygems/ivy-#{name}-#{version}#{ext}" if rs =~ /ivy/
    end
  end
end