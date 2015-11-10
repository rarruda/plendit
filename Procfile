web: bundle exec passenger start -p $PORT --max-pool-size 3
resque: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=8 QUEUE=* bundle exec rake resque:work
resque-scheduler: env RESQUE_SCHEDULER_INTERVAL=10 bundle exec rake environment resque:scheduler
