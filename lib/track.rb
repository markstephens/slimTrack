module FT
  module Analytics
    
    class Track

      attr_reader :errors
      
      TYPES = [:page, :link, :event, :log]
      
      METHODS = [:type, :clickid, :cookies, :params, :agent, :headers, :url, :remote_ip, :date]
      METHODS.each { |m| attr_accessor m }
      
      def initialize(type, info)
        if type == :load
          METHODS.each { |method|
            send "#{method}=", info[method]
          }
        else
          @type = type
          @cookies = info.request.cookies
          @headers = info.request.env
          @params = JSON.parse(info.request['d'])
          @clickid = @params["clickID"]
          @agent = info.request.user_agent
          @url = info.request.referrer
          @remote_ip = info.request.ip
          @date = Time.now
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
        
        errors << 'Missing clickID' if clickid.nil?
        errors << "Type must be one of: #{TYPES.join(', ')}. Got #{type}" unless TYPES.include? type
        
        
        @errors = errors unless errors.length.zero?
      end
      
    end
  end
end

