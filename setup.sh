# ruby on rails setup script
# should be run once after git clone

# install folder setting. this is necessory not to break other applications environment
bundle config set path 'vendor/bundle'
# install required gems
bundle install

# install dartsass
bundle exec rails dartsass:install
