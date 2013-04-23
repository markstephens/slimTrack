require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'analytics')

require 'sinatra/base'
require 'yui/compressor'
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
      # Constants
      # =========================
      PROFILES = Dir.glob(File.join(ROOT, "javascript", "profiles", "*.js")).collect { |version| File.basename version, '.js' }
      VERSIONS = Dir.glob(File.join(ROOT, "javascript", "base", "*.js")).collect { |version| File.basename version, '.js' }
    
      
      
      
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
      get Regexp.new "(/#{PROFILES.collect{ |p| Regexp.escape p }.join('|')})?/(latest|#{VERSIONS.collect{ |v| Regexp.escape v }.join('|')})(\.min)?\.js" do |profile, version, minified|
        version = VERSIONS.sort.last if version == 'latest'
        base_file = File.join(ROOT, "javascript", "base", "#{version}.js")
        profile_file = File.join(ROOT, "javascript", "profiles", "#{profile}.js")
        
        halt 404, {'Content-Type' => 'text/plain'}, 'Not found' unless File.exists? base_file
        halt 404, {'Content-Type' => 'text/plain'}, 'Not found' unless File.exists? profile_file unless profile.nil?
        
        file_content = File.open(base_file).read
        file_content += File.open(profile_file).read unless profile.nil?
        file_content.sub!("**SLIMTRACKVERSION**", [(profile || 'BASE'),version,('min' if minified)].compact.join('-'))

        content_type 'text/javascript'
        
        # Caching
        if settings.production?
          expires 31536000, :public, :must_revalidate # 1 year
          last_modified File.stat(file).mtime
          etag Digest::SHA1.hexdigest(file_content)
        end
        
        if minified.nil?
          body file_content
        else
          compressor = YUI::JavaScriptCompressor.new :munge => true
          body compressor.compress(file_content)
        end
      end
      
      
      
      
      # =========================
      # Tracking
      # =========================
      get Regexp.new "/(#{TYPES.collect{ |t| Regexp.escape t }.join('|')})" do |path|
        track = Track.new path.to_sym, self
        halt 500, track.errors.to_json if track.has_errors?

        track.headers.each { |k,v|
          logger.info "#{k}\t#{v}"
        }
        
        track.save
        
        status 200
        #headers # TODO No caching
      end

      
      
      
      # =========================
      # Error pages
      # =========================
      not_found do
        'This is nowhere to be found.'
      end

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

