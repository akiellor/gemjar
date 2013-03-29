require 'gemjar/artifact_repository'
require 'sinatra/base'
require 'gemjar/maven_path'

module Gemjar
  class App < Sinatra::Base
    before('*.sha1') { content_type 'plain/text' }
    before('*.md5') { content_type 'plain/text' }
    before('*.xml') { content_type 'application/xml' }
    before('*.pom') { content_type 'application/xml' }

    def self.get_or_head url_pattern, &block
      head url_pattern, &block
      get url_pattern, &block
    end

    def self.get_artifact url_pattern, &block
      head url_pattern do |name, version|
        artifact_repository = ArtifactRepository.new(Gemjar::WORK_DIRECTORY)

        artifact_repository.ensure(name, version) or raise Sinatra::NotFound

        status 200
      end

      get url_pattern do |name, version|
        artifact_repository = ArtifactRepository.new(Gemjar::WORK_DIRECTORY)

        gem_jar = artifact_repository.ensure(name, version) or raise Sinatra::NotFound

        self.instance_exec gem_jar, &block
      end
    end

    def self.get_maven_artifact url_pattern, &block
      head url_pattern do |maven_path_string|
        maven_path = Gemjar::MavenPath.parse(maven_path_string)

        artifact_repository = ArtifactRepository.new(Gemjar::WORK_DIRECTORY)

        artifact_repository.ensure(maven_path.artifact, maven_path.version) or raise Sinatra::NotFound

        status 200
      end

      get url_pattern do |maven_path_string|
        maven_path = Gemjar::MavenPath.parse(maven_path_string)

        artifact_repository = ArtifactRepository.new(Gemjar::WORK_DIRECTORY)

        gem_jar = artifact_repository.ensure(maven_path.artifact, maven_path.version) or raise Sinatra::NotFound

        self.instance_exec gem_jar, &block
      end
    end

    get_artifact "/jars/org.rubygems/:name-:version.jar" do |gem_jar|
      send_file gem_jar.jar.path, :filename => gem_jar.jar.path
    end

    get_artifact "/jars/org.rubygems/:name-:version.jar.sha1" do |gem_jar|
      body gem_jar.jar.sha1
    end

    get_artifact "/jars/org.rubygems/:name-:version.jar.md5" do |gem_jar|
      body gem_jar.jar.md5
    end

    get_artifact "/ivys/org.rubygems/ivy-:name-:version.xml" do |gem_jar|
      body gem_jar.ivy.content
    end

    get_artifact "/ivys/org.rubygems/ivy-:name-:version.xml.sha1" do |gem_jar|
      body gem_jar.ivy.sha1
    end

    get_artifact "/ivys/org.rubygems/ivy-:name-:version.xml.md5" do |gem_jar|
      body gem_jar.ivy.md5
    end

    get_maven_artifact %r{^/maven(/org/rubygems/.*\.pom)$} do |gem_jar|
      body gem_jar.pom.content
    end

    get_maven_artifact %r{^/maven(/org/rubygems/.*\.pom)\.sha1$} do |gem_jar|
      body gem_jar.pom.sha1
    end

    get_maven_artifact %r{^/maven(/org/rubygems/.*\.pom)\.md5$} do |gem_jar|
      body gem_jar.pom.md5
    end

    get_or_head %r{^/ping[/]?$} do
    end

    get_or_head %r{^/maven[/]?$} do
    end

    get_or_head(%r{^/maven/.*?\-sources\.jar$}) { 404 }

    get_or_head(%r{^/maven/.*?\-sources\.jar\.md5$}) { 404 }

    get_or_head(%r{^/maven/.*?\-sources\.jar\.sha1$}) { 404 }

    get_maven_artifact %r{^/maven(/org/rubygems/.*\.jar)$} do |gem_jar|
      send_file gem_jar.jar.path, :filename => gem_jar.jar.path
    end

    get_maven_artifact %r{^/maven(/org/rubygems/.*\.jar)\.sha1$} do |gem_jar|
      body gem_jar.jar.sha1
    end

    get_maven_artifact %r{^/maven(/org/rubygems/.*\.jar)\.md5$} do |gem_jar|
      body gem_jar.jar.md5
    end
  end
end