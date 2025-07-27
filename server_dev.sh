# this is server start script

# dartsass watches bootstrap update
bundle exec rails dartsass:watch 1>> log/dartsass.log 2>&1 &

# start server
bundle exec rails s 2>> log/server.log 2>&1 &

# they are run in background, when server stop, need to be killed manually