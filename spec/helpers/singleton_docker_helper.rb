require 'singleton'

class SingletonDockerImage
  include Singleton

  attr_accessor :id
end

class SingletonDockerContainer
  include Singleton

  attr_accessor :id
end