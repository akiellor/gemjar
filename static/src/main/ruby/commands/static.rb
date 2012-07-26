require 'clamp'
require 'aws'
require 'yaml'
require 'pathname'

module Commands
  class Static < Clamp::Command

    option ["-b", "--bucket"], "the S3 bucket to install the static files into", :attribute_name => :bucket

    option ["-a", "--auth-file"], "the amazon auth file to use", :attribute_name => :auth_file

    parameter "DIRECTORY", "the directory to deploy", :attribute_name => :directory

    def execute
      auth = Authentication.load(auth_file)

      Website.new(auth, bucket).install directory
    end
  end

  class Authentication
    def self.load filename
      yaml = YAML.load_file(File.expand_path(filename))
      new yaml['access_key_id'], yaml['secret_access_key']
    end

    attr_reader :access_key_id, :secret_access_key

    def initialize access_key_id, secret_access_key
      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
    end
  end

  class Website
    def initialize auth, bucket_name
      @auth = auth
      @bucket_name = bucket_name
    end

    def install directory
      s3 = AWS::S3.new(:access_key_id => @auth.access_key_id, :secret_access_key => @auth.secret_access_key)
      if s3.buckets.collect(&:name).include? @bucket_name
        s3.buckets[@bucket_name].clear!
      end

      bucket = s3.buckets.create(@bucket_name)

      bucket.policy = {
          "Version" => "2008-10-17",
          "Statement" => [
              {
                  "Sid" => "PublicReadForGetBucketObjects",
                  "Effect" => "Allow",
                  "Principal" => {"AWS" => "*"},
                  "Action" => ["s3:GetObject"],
                  "Resource" => ["arn:aws:s3:::#@bucket_name/*"]
              }
          ]
      }.to_json

      Dir[File.expand_path("**/*", directory)].select {|f| File.file?(f) }.each do |file|
        object_key = Pathname.new(file).relative_path_from(Pathname.new(directory)).to_s

        bucket.objects.create object_key, :file => file
      end
    end
  end
end