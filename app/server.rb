require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'analytics')
require File.join(ROOT, 'lib', 'javascript')

require 'sinatra/base'
require 'digest/sha1'

module FT
  module Analytics
    class Server < Sinatra::Base
      set :root, ROOT
      set :erb, :layout_options => { :views => 'views/layouts' }, :layout => :documentation

      configure :development do
        enable :logging
      end
      
      
      
      
      # =========================
      # Static
      # =========================
      get '/' do
        @profiles = PROFILES
        @versions = VERSIONS
        erb :index
      end
      
      get /\/(documentation|test|redis|runner|failures)/ do |page|
        case page
        when 'redis' then @tags = FT::Analytics::tags
        when 'runner' then @logs = FT::Analytics::logs
        when 'failures' then @failures = FT::Analytics::failures
        end
        
        erb page.to_sym
      end
      
      
      
      
      # =========================
      # JS file, profiled, versioned
      # =========================
      get Regexp.new "/?(#{PROFILES.collect{ |p| Regexp.escape p }.join('|')})?/(latest|#{VERSIONS.collect{ |v| Regexp.escape v }.join('|')})(\.min)?\.js" do |profile, version, minified|
        begin
          js = FT::Analytics::Javascript.new :version => version, :profile => profile, :minified => minified
        rescue => e
          halt 404, {'Content-Type' => 'text/plain'}, e.message
        end
        
        content_type 'text/javascript'
        
        # Caching
        if settings.production?
          expires 31536000, :public, :must_revalidate # 1 year
          last_modified js.last_modified
          etag Digest::SHA1.hexdigest(js.to_s)
        end
        
        body js.to_s
      end
      
      
      
      
      # =========================
      # Tracking
      # =========================
      get Regexp.new "/(#{TYPES.collect{ |t| Regexp.escape t }.join('|')})" do |path|
        track = Track.new path.to_sym, self
        halt 500, track.errors.to_json if track.has_errors?

        #track.headers.each { |k,v|
        #  logger.info "#{k}\t#{v}"
        #}
        
        track.save
        
        # Wait for 2 secs, for testing async
        sleep 2 if ENV['testsync']
        
        status 200
        #headers # TODO No caching
      end

      
      
      
      # =========================
      # Error pages
      # =========================
#      not_found do
#        'This is nowhere to be found.'
#      end

      error do
        'Sorry there was a nasty error - ' + env['sinatra.error'].name
      end

      
      
      
      # Run if calling ruby file directly
      run! if app_file == $0 
      
      
      
      
      private
      
      def versions
        VERSIONS
      end
      
      def profiles
        PROFILES
      end
    end
  end
end

