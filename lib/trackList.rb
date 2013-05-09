module FT
  module Analytics
    class TrackList < Array
    
      def find_by_clickid(clickid)
        collect { |t| t if t.clickid == clickid }.compact
      end
      
      def find_by_type(type)
        collect { |t| t if t.type == type }.compact
      end
      
      def clickids
        collect { |t| t.clickid }.uniq        
      end
      
      def is_mergable?
        length != clickids.length
      end
      
      def merge
        if is_mergable?
          merged = TrackList.new
          
          clickids.each { |clickid|
            to_merge = find_by_clickid clickid
         
            # Merge page and data
            page = to_merge.find_by_type(:page).first
            
            if page.nil? # No page tag, could've been sent on previous batch
              merged += to_merge.find_by_type(:data)
            else
              to_merge.find_by_type(:data).each { |data|
                page.merge data
              }
            
              merged << page
            end
                        
            # Events
            events = to_merge.find_by_type(:event)
            if events.length > 0
              event = events.first
              
              events.slice(1..-1).each { |e|
                event.merge e
              }
            
              merged << event
            end
            
            # Include the things that can't be merged
            (FT::Analytics::TYPES - [:page,:data,:event]).each { |type|
              merged += to_merge.find_by_type type
            }
          }
          
          merged
        else
          self
        end
      end
      
      
      
      
      # Override Enumerable methods
      alias_method :orig_collect, :collect
      alias_method :orig_compact, :compact
      alias_method :orig_uniq, :uniq
      
      def collect
        TrackList.new orig_collect { |obj| yield obj }
      end
      
      def compact
        TrackList.new orig_compact
      end
      
      def uniq
        TrackList.new orig_uniq
      end
      
    end
  end
end

