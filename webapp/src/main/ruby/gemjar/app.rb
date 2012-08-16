require 'gemjar/artifact'
require 'sinatra/base'

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
      send_file gem_jar.jar.path, :filename => gem_jar.jar.path
    end

    get "/jars/org.rubygems/:name-:version.jar.sha1" do |name, version|
      gem_jar = Artifact.ensure(name, version) or raise Sinatra::NotFound
      body gem_jar.jar.sha1
    end

    get "/jars/org.rubygems/:name-:version.jar.md5" do |name, version|
      gem_jar = Artifact.ensure(name, version) or raise Sinatra::NotFound
      body gem_jar.jar.md5
    end

    get "/ivys/org.rubygems/ivy-:name-:version.xml" do |name, version|
      gem_jar = Artifact.ensure(name, version) or raise Sinatra::NotFound
      body gem_jar.ivy.content
    end

    get "/ivys/org.rubygems/ivy-:name-:version.xml.sha1" do |name, version|
      gem_jar = Artifact.ensure(name, version) or raise Sinatra::NotFound
      body gem_jar.ivy.sha1
    end

    get "/ivys/org.rubygems/ivy-:name-:version.xml.md5" do |name, version|
      gem_jar = Artifact.ensure(name, version) or raise Sinatra::NotFound
      body gem_jar.ivy.md5
    end
  end
end