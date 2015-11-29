source "https://rubygems.org"

group :test do
  gem 'rake'
  gem 'rspec-wait'
  gem 'git'
  gem 'docker-api'
  gem 'serverspec', '~> 2.24' # Docker 1.8 support
  gem 'specinfra', '~> 2.44' # for Docker backend + send_file & commit (https://github.com/mizzy/specinfra/releases/tag/v2.43.11)
end

group :development do
  gem 'travis'
  gem 'rb-fsevent'
  gem 'guard', '~> 2.13'
  gem 'guard-rspec'

  case RUBY_PLATFORM
  when /darwin/
    gem 'terminal-notifier-guard'
    gem 'growl'
  when /linux/
    gem 'libnotify'
  when /win32/
    gem 'rb-notifu'
  end
end
