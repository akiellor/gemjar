require 'aws-sdk'
require 'gemjars/deux/streams'

module Gemjars
  module Deux
    class AWSStore
      def self.from_file path
        config = YAML.load(File.read(File.expand_path(path)))
        bucket_name = config['bucket']
        s3 = AWS::S3.new(access_key_id: config['access_key_id'], secret_access_key: config['secret_access_key'])
        bucket = s3.buckets.create(bucket_name)
        executor = Java::JavaUtilConcurrent::Executors.new_fixed_thread_pool(10)
        new(bucket, executor)
      end

      def initialize bucket, executor
        @bucket = bucket
        @executor = executor
      end

      def put name, opts = {}
        r, w = Streams.pipe_channel
        @executor.submit proc {
          begin
            @bucket.objects.create name, Streams.to_input_stream(r).to_io, {:estimated_content_length => 2048 * 1024}.merge(opts)
          rescue => e
            puts e
          end
        }.to_java(Java::JavaLang::Runnable)
        w
      end

      def get name
        return unless @bucket.objects[name].exists?

        r, w = Streams.pipe_channel
        @executor.submit proc {
          begin
            @bucket.objects[name].read do |chunk|
              w.write Streams.to_buffer(chunk)
            end
          rescue => e
            puts e
          ensure
            w.close
          end
        }.to_java(Java::JavaLang::Runnable)
        r
      end
    end
  end
end
