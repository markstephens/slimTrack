require 'time'
require 'json'
require 'rack'
require 'redis'

ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require File.join(ROOT, 'lib', 'track')
require File.join(ROOT, 'lib', 'trackList')

module FT  
  module Analytics

    # =========================
    # Constants
    # =========================
    PROFILES = Dir.glob(File.join(ROOT, "javascript", "profiles", "*.js")).collect { |version| File.basename version, '.js' }
    VERSIONS = Dir.glob(File.join(ROOT, "javascript", "base", "*.js")).collect { |version| File.basename version, '.js' }
    
    REDIS = if ENV["REDISCLOUD_URL"]
      redis_uri = URI.parse ENV["REDISCLOUD_URL"]
      Redis.new :driver => :hiredis, :host => redis_uri.host, :port => redis_uri.port, :password => redis_uri.password
    else
      Redis.new :driver => :hiredis
    end
    
    TAG_LIST = 'tags'
    LOG_LIST = 'logs'
    FAILURE_LIST = 'failure'
    CAPI_STORE = 'capi'
    QUOVA_STORE = 'quova'
    TYPES = [:page, :data, :link, :event, :log]

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
      tags = TrackList.new
      
      REDIS.lrange(TAG_LIST, 0, -1).each { |tag|
        tags << Track.new_from_store(tag)
      }
      
      tags
    end
    
    def self.failure(json)
      REDIS.rpush FAILURE_LIST, json
    end  
    
    def self.failures
      REDIS.lrange(FAILURE_LIST, 0, -1)
    end
    
    def self.pop_tags
      # This shouldn't need to be blocking or aware of conflicts as redis doesn't work that way.
      # Index starts at 1!
      raw_tags = (1..REDIS.llen(TAG_LIST)).collect {
        REDIS.lpop TAG_LIST
      }
      
      tags = TrackList.new
      
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