source "https://rubygems.org"
ruby "3.1.2"

gem "rails", "~> 7.0.4", ">= 7.0.4.2"
gem "sprockets-rails"
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "bcrypt", "~> 3.1.7"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem "nio4r", ">= 2.5.9"

# 本番DBは PostgreSQL
gem "pg", "~> 1.5"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  # 開発・テストだけ sqlite3 を使う
  gem "sqlite3", "~> 1.7"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

# ここからアプリ用の他のgem
gem "ruby-openai"
gem "dotenv-rails"
gem "bootstrap", "~> 5.3.0.alpha3"
gem "jquery-rails"
gem "aws-sdk-s3", require: false
gem "mini_magick"
gem "streamio-ffmpeg"
gem "rails-i18n"
gem "google-api-client", "~> 0.11"
gem "image_processing", "~> 1.2"
gem "youtube-dl.rb"
gem "terrapin"
gem "acts-as-taggable-on"