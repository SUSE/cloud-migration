source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.7'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

#gem 'cheetah', :path => '/tmp/cheetah'

# Use machinery for system analysis
# https://github.com/SUSE/machinery
#gem 'machinery-tool', '~> 1.23.0', require: 'machinery'
#gem 'machinery-tool', require: 'machinery', :path => '/tmp/machinery'
gem 'machinery-tool', require: 'machinery', git: 'https://github.com/guangyee/machinery.git', branch: 'salt_states'

# Use net-ssh for tasks not included in machinery
gem 'net-ssh'
# required by 'net-ssh'
gem 'ed25519'
gem 'bcrypt_pbkdf'

# Use DelayedJob as ActiveJob backend
gem 'delayed_job_active_record'
gem 'daemons'

# User Serializer to format REST API JSON objects
gem 'active_model_serializers'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.5'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'shoulda-matchers', '~> 3.1'
  gem 'database_cleaner'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Abstract method gem
#gem 'abstract_method', '~>1.2'
# AWS-SDK
gem 'aws-sdk'
