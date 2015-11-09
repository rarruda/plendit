class TestJob
  def self.queue
    :sloth
  end

  def self.perform
    puts 'I like to sleep'
    sleep 2
    puts 'That was a good nap'
  end
end