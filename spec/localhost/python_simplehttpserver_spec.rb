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

      describe process("python") do
        it { should be_running }
        its(:args) { should match /-m SimpleHTTPServer 8080/ }
      end

      describe port(8080) do
        it { should be_listening }
      end
    end
  end
end
