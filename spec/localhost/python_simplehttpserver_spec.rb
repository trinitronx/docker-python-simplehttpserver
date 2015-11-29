require 'spec_helper'
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'helpers')
require 'singleton_docker_helper'

describe 'trinitronx/python-simplehttpserver' do
  RSpec.shared_context "trinitronx/python-simplehttpserver image" do
    def image
      # This image will now be cached by docker
      # and used for the rest of the RSpec tests
      # We will instantiate a SingletonDockerImage to store & retrieve the id throughout
      # Then return the Docker::Image class for that image ID
      singleton_image = SingletonDockerImage.instance
      if ! singleton_image.id.nil?
        Docker::Image.get(singleton_image.id)
      else
        img = Docker::Image.build_from_dir('.')
        singleton_image.id = img.id
        img
      end
    end

    before(:all) do
      # Use Global Variable so we always reference the SAME image
      
      puts "Built Image: #{image.id}"
      
      # Tag it with the REPO and git COMMIT ID
      @repo = ! ENV['REPO'].nil? ? ENV['REPO'] : 'trinitronx/python-simplehttpserver'

      require 'git'
      g = Git.open(Dir.pwd)
      head = g.gcommit('HEAD').sha if g.index.readable?

      @commit = ! ENV['COMMIT'].nil? ? ENV['COMMIT'] : head[0..7]
      @commit ||= 'rspec-testing' # If we failed to get a commit sha, label it with this as default
      puts "Tagging Image: #{image.id} with: #{@repo}:#{@commit}"
      image.tag( :repo => @repo, :tag => @commit, force: true)

      set :os, family: :linux  # The busybox image is actually buildroot according to /etc/os-release, SpecInfra does not support this well
      set :backend, :docker
      set :docker_image, image.id

      # Busybox image uses:
      # # cat /etc/os-release
      # NAME=Buildroot
      # VERSION=2014.02
      # ID=buildroot
      # VERSION_ID=2014.02
      # PRETTY_NAME="Buildroot 2014.02"
      # uname -a
      # Linux 8aaca671f421 4.1.13-boot2docker #1 SMP Fri Nov 20 19:05:50 UTC 2015 x86_64 GNU/Linux
    end
  end

  describe 'trinitronx/python-simplehttpserver image' do
    include_context "trinitronx/python-simplehttpserver image"

    context "inside Docker Container" do
      before(:all) {
        t3 = Time.now
        puts "Dockerfile_spec.rb: Running 'inside Docker Container' tests on: #{image.id} at: #{t3}.#{t3.nsec}"
      }

      describe file('/bin/python') do
        it { should exist }
        it { should be_file }
      end

      describe command("ps -o args= | grep python | grep -v grep | head -n1") do
        its(:stdout) { should match /-m SimpleHTTPServer 8080/ }
      end

      describe port(8080) do
        # Avoid race condition when python is running but hasn't grabbed the port yet...
        it "grabs port 8080" do
          wait_for { port(8080) }.to be_listening
        end
        it { is_expected.to be_listening }
      end

      context "when serving a test file" do
        before(:all) do
          Specinfra::Runner.send_file(File.join(File.dirname(__FILE__), '..', 'fixtures', 'helloworld.txt'), '/var/www/')
        end

        describe file('/var/www/helloworld.txt') do
          it { should be_file }
        end

        describe port(8080) do
          # Avoid race condition when python is running but hasn't grabbed the port yet...
          it "grabs port 8080" do
            wait_for { port(8080) }.to be_listening
          end
          it { is_expected.to be_listening }
        end

        describe command('wget -O - http://localhost:8080/helloworld.txt') do
          its(:stdout) { should match /^hello simple world$/ }
          its(:stderr) { is_expected.not_to match /can't connect/ }
          its(:exit_status) { is_expected.to eq 0 }
        end

        describe command('wget -O - http://localhost:8080/') do
          its(:stdout) { should match /Directory listing for \// }
          its(:stdout) { should match /<a href="helloworld\.txt">helloworld\.txt<\/a>/ }
          its(:stderr) { is_expected.not_to match /can't connect/ }
          its(:exit_status) { is_expected.to eq 0 }
        end
      end
    end
  end
end
