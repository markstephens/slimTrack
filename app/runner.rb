require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'analytics')

module FT
  module Analytics
    class Runner
      
      attr_reader :tags
      
      def initialize
        start = Time.now
        
        # Get all tags and remove them from storage (in-case more than one runner running)
        @tags = FT::Analytics::pop_tags
        
        # merge similar tags
        # merge
        # add additional data
        # send tags to correct location
        # delete tag from store
        
        FT::Analytics::log "Processed #{tags.length} tags in #{Time.now - start}."
      end
      
      private
      
       
      
    end
  end
end

# Call if running ruby file directly
FT::Analytics::Runner.new if __FILE__ == $0