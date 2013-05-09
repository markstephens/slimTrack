require 'mongo'
require 'bson'

module FT
  module Analytics
    
    MONGODB = if ENV['MONGOLAB_URI']
      uri  = URI.parse ENV['MONGOLAB_URI']
      conn = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
      conn.db(uri.path.gsub(/^\//, ''))
    else
      Mongo::MongoClient.new("localhost", 27017).db("capi")
    end
    
    MONGO_COLLECTION = MONGODB.collection("pages")
    
    class Capi
      
      attr_reader :sub_type, :asset_type, :sitemap, :edition, :title
      #  channel	desktop
      #  AssetType	page
      #  sm	Sections.Front page
      #  ed	UK
      #  WT.ti	World business, finance, and political news from the Financial Times - FT.com
      #  dfp_site	ftcom.5887.home
      #  dfp_zone	uk
      #  dfp_targeting	;pt
      #  ad_refresh	yes
      #  FTSection	1hom
      #  FTPage	1homeuk
      #  FTSite	ftcom
      
      def self.get(track)
        data = if track.uuid
          MONGO_COLLECTION.find_one 'uuid' => track.uuid
        else
          MONGO_COLLECTION.find_one 'url' => track.url
        end
        
        # If no data, get from capi?
        
        data
      end

    end
  end
end
