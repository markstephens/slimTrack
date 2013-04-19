module FT
  module Analytics
    class Track

      TYPES = [:page, :link, :event, :log]
      
      attr_reader :errors
      METHODS = [:type, :clickid, :cookies, :params, :agent, :headers, :url, :remote_ip, :date]
      METHODS.each { |m| attr_accessor m }
      
      def initialize(type, info)
        if type == :load
          METHODS.each { |method|
            send "#{method}=", info[method]
          }
        else
          self.type = type
          self.cookies = info.request.cookies
          self.headers = info.request.env
          self.params = info.request['d']
          self.clickid = params.delete "clickID"
          self.agent = info.request.user_agent
          self.url = info.request.referrer
          self.remote_ip = info.request.ip
          self.date = Time.now
        end
        
        validate
      end
      
      # =========================
      # "New" helpers
      # =========================
      def self.page(server)
        new :page, server
      end
      
      def self.link(server)
        new :link, server
      end
      
      def self.event(server)
        new :event, server
      end
      
      def self.log(server)
        new :log, server
      end
      
      def self.new_from_store(json)
        new :load, json
      end
      
      def has_errors?
        !@errors.nil?
      end
      
      # =========================
      # Storage
      # =========================
      def save
        REDIS.rpush REDIS_LIST, to_json
      end
      
      def self.load_all
        REDIS.lrange(REDIS_LIST, 0, -1).collect { |r|
          json = JSON.parse(r)
          json.default_proc = proc{ |h, k| h.key?(k.to_s) ? h[k.to_s] : nil}
          new_from_store json
        }
      end
      
      # =========================
      # Setters
      # =========================
      def type=(type)
        @type = type.to_sym
      end
      def date=(date)
        @date = if date.class == Time
          date
        else
          Time.parse date
        end
      end
      def params=(params)
        @params = if params.class == Hash
          params
        else
          JSON.parse params
        end
      end
      
      # =========================
      # Output
      # =========================
      def to_json
        METHODS.inject({}) { |h,method| h[method] = send method; h }.to_json
      end
      
      # =========================
      # For testing
      # =========================
      def self.irb
        new :load, METHODS.inject({}) { |h,method| h[method] = method.to_s; h }
      end
      
      private
      
      def validate
        errors = []
        
        errors << "Missing clickID. ClickID is required if type is #{type}." if clickid.nil? if [:page, :link, :event].include? type
        errors << "Type must be one of: #{TYPES.join(', ')}. Got #{type} (#{type.class})." unless TYPES.include? type
        
        
        @errors = errors unless errors.length.zero?
      end
      
    end
  end
end

