require 'rubygems'
require 'aws'
require 'net/ssh'
require 'net/scp'
require 'yaml'
require 'timeout'

webapp = ARGV.pop

config = YAML.load File.read(File.expand_path("~/.gemjars"))

s3 = AWS::S3.new(
    :access_key_id => config['access_key_id'],
    :secret_access_key => config['secret_access_key'])

bucket = s3.buckets.detect {|b| b.name == "gemjars" } || s3.buckets.create('gemjars', :acl => :public_read)
bucket.acl = :public_read

gemjars_deb = bucket.objects[File.basename(webapp)]
gemjars_deb.write(:file => File.expand_path(webapp), :acl => :public_read)

puts "Debian Package uploaded to: #{gemjars_deb.public_url}"

ec2 = AWS::EC2.new(
    :region => 'us-east-1',
    :access_key_id => config['access_key_id'],
    :secret_access_key => config['secret_access_key'])

key_pair = ec2.key_pairs.detect { |kp| kp.name == config['key_pair']["name"] } || ec2.key_pairs.import(config['key_pair']["name"], File.read(File.expand_path(config['key_pair']["location"])))

security_group = ec2.security_groups.detect { |sg| sg.name == 'gemjars' } || ec2.security_groups.create('gemjars')

required_permissions = [[:tcp, 80..80], [:tcp, 8080..8080], [:tcp, 22..22]]

available_permissions = security_group.ip_permissions.map do |permission|
  [permission.protocol, permission.port_range]
end

additional_permissions = required_permissions - available_permissions

additional_permissions.each do |permission|
  security_group.authorize_ingress(permission[0], permission[1])
end

user_data = <<EOS
#!/bin/sh -e
sudo apt-get update
sudo apt-get -f install
sudo apt-get install -y openjdk-6-jdk
sudo apt-get install -y zip
wget \"#{gemjars_deb.public_url}\"
ls gemjar*.deb | xargs sudo dpkg -i
sudo service gemjars start
EOS

instance = ec2.instances.create(
    :monitoring => {:enabled => false},
    :instance_type => 'm1.small',
    :image_id => "ami-eafa5883",
    :security_group_ids => [security_group.name],
    :key_name => key_pair.name,
    :user_data => user_data)

$stdout << "Waiting for instance..."
($stdout << "."; sleep 1) while instance.status != :running

puts instance.public_dns_name

Timeout::timeout(360) do
  up = false
  until up
    puts "Checking: http://#{instance.public_dns_name}:8080/ping"
    begin
      res = Net::HTTP.get_response(URI.parse("http://#{instance.public_dns_name}:8080/ping"))
      up = res.code == "200"
    rescue Errno::ECONNREFUSED => e
      $stdout << "."
    end
    sleep 10
  end
end