require 'resque/errors'

class SleepingJob
  @queue = :test

  def self.perform(time = 100)
    sleep(time)
  rescue Resque::TermException
    sleep(2)
  end
end