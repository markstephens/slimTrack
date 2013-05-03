require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'analytics')
require File.join(ROOT, 'lib', 'capi')

module FT
  module Analytics
    class Runner
      
      attr_reader :tags
      
      def initialize
        start = Time.now
        
        # Get all tags and remove them from storage (in-case more than one runner running)
        tags = FT::Analytics::pop_tags
        
        if tags.length.zero?
          FT::Analytics::log "Nothing to do."
          exit
        end
        
        # merge similar tags
        tags = tags.merge
        
        # add additional data
        tags.each { |track|
          #begin
          # cAPI
          capi = FT::Analytics::Capi.get track
            
          puts capi.first.inspect
          
          [:sitemap, :edition, :title, :dfp_site, :dfp_zone, :dfp_targeting, :section, :page].each { |m|
            track.meta[m] = capi.first[m]
          } if capi
            
          puts "track.meta #{track.meta.inspect}"
            
          # Quova
          #quova track.ip
            
          FT::Analytics::log "I would send #{track.url}"
          #rescue => e
          #  FT::Analytics::log "ERROR: #{e.message}"
          #  FT::Analytics::failure track
          #end
        
          # send tags to correct location
        }
        
        FT::Analytics::log "Processed #{tags.length} tags in #{Time.now - start}."
      end
            
    end
  end
end

# Call if running ruby file directly
FT::Analytics::Runner.new if __FILE__ == $0