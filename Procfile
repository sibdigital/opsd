#web: bundle exec unicorn --config-file config/unicorn.rb --host ${HOST:="127.0.0.1"} --port ${PORT:="8080"} --env ${RAILS_ENV:="development"}
web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: bundle exec rake jobs:work
backup: ./packaging/scripts/backup
check: ./packaging/scripts/check
