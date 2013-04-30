require 'yui/compressor'

module FT
  module Analytics
    class Javascript
      
      attr_reader :version, :profile, :minified
      
      def initialize(args = {})
        settings = {
          :version => 'latest',
          :profile => nil,
          :minified => false
        }.merge args
        
        settings[:version] = VERSIONS.sort.last if settings[:version] == 'latest'
        
        throw ArgumentError.new "version is invalid, must be one of: #{VERSIONS.join(', ')}." unless VERSIONS.include? settings[:version]
        throw ArgumentError.new "profile is invalid, must be one of: #{PROFILES.join(', ')}. Got #{settings[:profile]}" unless PROFILES.include? settings[:profile] unless settings[:profile].nil?
        
        @version = settings[:version]
        @profile = settings[:profile]
        @minified = settings[:minified]
        
        @base_file = File.join(ROOT, "javascript", "base", "#{version}.js")
        @profile_file = File.join(ROOT, "javascript", "profiles", "#{profile}.js") unless profile.nil?
        
        throw Exception.new "#{version}.js cannot be found in the js directory" unless File.exists? @base_file
        throw Exception.new "#{profile}.js cannot be found in the js directory" unless File.exists? @profile_file unless profile.nil?
        
        @file_content = File.open(@base_file).read
        @file_content += File.open(@profile_file).read unless profile.nil?
        @file_content.sub!("**SLIMTRACKVERSION**", [(profile || 'BASE'),version,('min' if minified)].compact.join('-'))
        
        minify! if minified
      end
      
      def minify!
        compressor = YUI::JavaScriptCompressor.new :munge => true
        @file_content = compressor.compress(@file_content)
      end
      
      def to_s
        @file_content
      end
      
      def last_modified
        if profile.nil?
          File.stat(@base_file).mtime
        else
          base_mtime = File.stat(@base_file).mtime
          profile_mtime = File.stat(@profile_file).mtime
          
          profile_mtime > base_mtime ? profile_mtime : base_mtime
        end       
      end
      
      def to_file(filename)
        f = File.open(filename, 'w')
        f.write to_s
        f.close
      end

    end
  end
end
