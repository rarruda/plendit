#@logger = Cabin::Channel.new
#@logger.subscribe(Logger.new(STDOUT))

LOG = Cabin::Channel.new
LOG.subscribe(STDOUT)

#LOG.level = Rails.env? 'production' ? :info : :debug
LOG.level = :debug