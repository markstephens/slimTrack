require 'sinatra/base'
require 'yui/compressor'
require 'digest/sha1'
require File.join(File.dirname(__FILE__), 'lib', 'track')

module FT
  module Analytics
    class Server < Sinatra::Base
      
      set :erb, :layout_options => { :views => 'views/layouts' }

      configure :development do
        enable :logging
      end
      
      # =========================
      # Static
      # =========================
      get '/' do
        @versions = versions
        erb :index, :layout => :documentation
      end
      
      get '/test' do
        erb :test, :layout => :documentation
      end
      
      # =========================
      # JS file, versioned
      # =========================
      get %r{\/(latest|\d+)(\.min)?\.js} do |version, minified|
        version = versions.sort.last if version == 'latest'
        file = File.join(File.dirname(__FILE__), "javascript", "#{version}.js")
        
        halt 404, {'Content-Type' => 'text/plain'}, 'Not found' unless File.exists? file
        
        file_content = File.open(file).read

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
      get '/page' do
        Track.page self
      end
      get '/link' do
        Track.link self
      end
      get '/event' do
        Track.event self
      end
      get '/log' do
        Track.log self
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
        Dir.glob(File.join(File.dirname(__FILE__), "javascript", "*.js")).collect { |version| File.basename version, '.js' }
      end
    end
  end
end

