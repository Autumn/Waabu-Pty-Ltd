require 'logger'

module Waabu
  class Log
    LOG = Logger.new('/home/site/dashboard/dashboard.log', 'daily')
    LOG.level = Logger::INFO

    def self.info message
      LOG.info message
    end

    def self.debug message
      LOG.debug message
    end

    def self.warn message 
      LOG.warn message
    end

    def self.fatal message
      LOG.fatal message
    end

  end
end

