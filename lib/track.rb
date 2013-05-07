module FT
  module Analytics
    class Track  
    
      attr_reader :errors
      METHODS = [:type, :clickid, :cookies, :params, :agent, :headers, :url, :remote_ip, :date, :channel, :meta, :user]
      METHODS.each { |m| attr_accessor m }
      
      def initialize(type, info)
        @meta = {}
        @user = {}
        
        if type == :load
          METHODS.each { |method|
            send "#{method}=", info[method]
          }
        else
          self.type = type
          self.cookies = info.request.cookies
          self.headers = info.request.env
          self.params = info.request.params
          self.clickid = params.delete "clickID"
          self.agent = info.request.user_agent
          self.url = (params.has_key?("url") ? params.delete("url") : info.request.referrer)
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
        hash = (json.class == Hash ? json : JSON.parse(json))
        hash.default_proc = proc{ |h, k| h.key?(k.to_s) ? h[k.to_s] : nil}
        
        new :load, hash
      end
      
      def has_errors?
        !@errors.nil?
      end
      
      # =========================
      # Storage
      # =========================
      def save
        FT::Analytics::tag to_json
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
      def url=(url)
        u = URI(url)
        self.params.merge Rack::Utils.parse_query(u.query) if u.query
        @url = "#{u.scheme}://#{u.host}#{u.path}"
      end
      
      def merge(other_track)
        params.merge! other_track.params
      end
      
      # =========================
      # Getters
      # =========================
      def channel
        # TODO logic to determine channel
        'desktop'
      end
      
      def ip
        (params.has_key?("overrideIpAddress") ? params["overrideIpAddress"] : info.request.ip)
      end
      
      def meta
        @meta unless @meta.values.length.zero? unless @meta.nil?
      end
      
      def user
        @user unless @user.values.length.zero? unless @user.nil?
      end
      
      def params
        p = @params
        p.merge! meta if meta
        p.merge! user if user
        p
      end
            
      # =========================
      # Output
      # =========================
      def to_json
        METHODS.inject({}) { |h,method| h[method] = send method; h }.to_json
      end
            
      def to_s
        "#<FT::Analytics::Track:#{object_id} @type=#{type}, @clickid=#{clickid}, @date=#{date}, @url=#{url}>"
      end
      alias_method :inspect, :to_s
      
      # =========================
      # For runner
      # =========================
      def uuid
        if params.has_key? :uuid
          params[:uuid]
        elsif /\/cms\/s?\/?\d?\/?([a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12})/.match url.to_s
          $1
        end
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
        
        errors << "Type must be one of: #{TYPES.join(', ')}. Got '#{type}'." unless TYPES.include? type
        errors << "Missing clickID. ClickID is required if type is #{type}." if clickid.nil? if [:page, :link, :event].include? type
        #errors << "URL is invalid: '#{url}'." unless url.scheme and url.host and url.path
        
        @errors = errors unless errors.length.zero?
      end
      
    end
  end
end

