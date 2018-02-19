source "http://rubygems.org"

#gem 'health-data-standards', :git => 'https://github.com/phema/health-data-standards.git', :branch => 'phema'
gem 'health-data-standards', path: '../health-data-standards'

gem 'rest-client'
gem 'rubyzip', '~> 1.2.1'

group :development do
  gem 'rake'
  gem 'pry', '~> 0.9.10'
  gem 'pry-nav', '~> 0.2.2'
end

group :test do
  gem 'factory_girl', '~> 4.1.0'
  gem "tailor", '~> 1.1.2'
  gem "cane", '~> 2.3.0'
  gem 'simplecov', :require => false
  gem 'webmock'

  gem "minitest", "~> 5.0"
  gem 'awesome_print', :require => 'ap'
end
