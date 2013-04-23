require 'time'
require 'json'
require 'redis'

ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require File.join(ROOT, 'lib', 'track')

module FT  
  module Analytics

    REDIS = Redis.new(:driver => :hiredis)
    TAG_LIST = 'tags'
    LOG_LIST = 'logs'
    FAILURE_LIST = 'failure'
    CAPI_STORE = 'capi'
    QUOVA_STORE = 'quova'
    TYPES = [:page, :link, :event, :log]

    # STORAGE
    def self.log(message)
      REDIS.rpush LOG_LIST, "#{Time.now}: #{message}"
    end  
    
    def self.logs
      REDIS.lrange(LOG_LIST, -500, -1).reverse
    end
    
    def self.tag(json)
      REDIS.rpush TAG_LIST, json
    end
    
    def self.tags
      REDIS.lrange(TAG_LIST, 0, -1).collect { |tag|
        Track.new_from_store tag
      }
    end
    
    def self.failure(json)
      REDIS.rpush FAILURE_LIST, json
    end  
    
    def self.failures
      REDIS.lrange(FAILURE_LIST, 0, -1)
    end
    
    def self.pop_tags
      # This should need to be blocking or aware of conflicts as redis doesn't work that way.
      # Index starts at 1!
      raw_tags = (1..REDIS.llen(TAG_LIST)).collect {
        REDIS.lpop TAG_LIST
      }
      
      tags = []
      
      raw_tags.each { |tag|
        begin
          tags << Track.new_from_store(tag)
        rescue => e
          log "ERROR: #{e.message}"
          failure tag
        end
      }
      
      tags
    end
    
  end
end