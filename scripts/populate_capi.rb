require 'bundler'
require 'mysql2'
require 'mongo'
require 'bson'

def time(&block)
  start = Time.now
  yield block
  puts "(#{Time.now - start} seconds)"
end

mysql = Mysql2::Client.new(:host => "localhost", :username => "admin", :password => "admin", :database => "publish")

mongodb = Mongo::MongoClient.new("localhost", 27017).db("capi")
collection = mongodb.collection("pages")

collection.remove

page_content = nil
article_content = nil

puts ''
puts 'Getting page content'
time do
  pc = mysql.query("SELECT page_id, name, value FROM page_metadata_entry")
  
  total = pc.count
  counter = 0
  
  page_content = pc.inject({}) { |h,row|
    counter += 1
    print "\b\b\b\b\b" + "#{((counter.to_f / total) * 100).round}%".ljust(5)
    
    h[row["page_id"]] = {} unless h.has_key? row["page_id"]
    h[row["page_id"]][row['name']] = row['value']
    
    h
  }

  print "\b\b\b\b\b100%  "
end

=begin
puts ''
puts 'Getting article content'
time do
  article_content = mysql.query("SELECT content_id,term_type,term_value FROM content_metadata_term")
  
  total = article_content.count
  counter = 0
  
  article_content.inject({}) { |h,row|
    counter += 1
    print "\b\b\b\b\b" + "#{((counter.to_f / total) * 100).round}%".ljust(5)
    
    h[row["content_id"]] = {} unless h.has_key? row["content_id"]
    h[row["content_id"]][row['term_type']] = row['term_value']
    
    h
  }

  print "\b\b\b\b\b100%  "
end
=end

puts ''

puts 'Running...'
time do
  urls = mysql.query("SELECT uuid, url, page_id, story_id FROM urls")
  
  total = urls.count
  counter = 0
  
  urls.each { |row|
    counter += 1
    print "\b\b\b\b\b\b\b" + "#{((counter.to_f / total) * 100).round(2)}%".ljust(7)
    
    data = {
      'url' => row["url"], 'uuid' => row['uuid']
    }
    
    if row["story_id"]
      # TODO article_content[row['story_id']]
      data.merge! 'asset_type' => 'story', 'sitemap' => '', 'edition' => '', 'title' => page_content[row['story_id']]
    else
      data.merge! 'asset_type' => 'page'

      if page_content.has_key? row['page_id']
        page = page_content[row['page_id']]
        
        data.merge! 'sitemap' => page['page/siteMapTerm'], 'edition' => '', 'title' => page['general/browserTitle'],
        'dfp_site' =>	page['advert/ftDFPSite'], 'dfp_zone' => page['advert/ftDFPZone'], 'dfp_targeting' => ';pt',
        'section' => page['advert/ftSection'], 'page' => page['advert/ftPage']
      end
    end
    
    collection.insert data
  }
  
  print "\b\b\b\b\b\b\b100%  "
end

puts ''

puts 'Creating indexes'
time do
  collection.create_index("url")
  collection.create_index("uuid")
end
