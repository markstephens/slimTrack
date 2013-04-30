desc "Start the webserver."
task :server do
  puts "SERVER\n"
  port = ENV["port"] || 5000
  system "bundle exec ruby app/server.rb -p #{port}" unless system "bundle exec rackup -p #{port}" unless system "foreman start -p #{port}"
end



desc "Start redis storage."
task :redis do
  puts "REDIS\n"
  system 'redis-server'
end



desc "Start the runner, and process tags."
task :runner do
  puts "RUNNER\n"
  system "bundle exec ruby app/runner.rb"
end



desc "Show versions and profiles available for build."
task :versions do
  puts "VERSIONS AND PROFILES\n"
  require File.join(File.expand_path(File.dirname(__FILE__)), 'lib', 'analytics')
  
  puts 'Versions'
  puts " - latest"
  FT::Analytics::VERSIONS.each { |version|
    puts " - #{version}"
  }
  puts 'Profiles'
  FT::Analytics::PROFILES.each { |profile|
    puts " - #{profile}"
  }  
  
  puts ''
end



directory 'target'

desc "Buld a version of JavaScript"
task :build => "target" do
  puts "BUILD\n"
  
  version = ENV["version"] || 'latest'
  profile = ENV["profile"]
  
  puts "Building: #{version} - #{profile || 'base'}."
  
  require File.join(File.expand_path(File.dirname(__FILE__)), 'lib', 'analytics')
  require File.join(ROOT, 'lib', 'javascript')
  include FT::Analytics
  
  Dir.glob(File.join(ROOT, 'target', '*.js')) { |filename|
    File.delete filename
  }
  
  js = FT::Analytics::Javascript.new :version => version, :profile => profile, :minified => false
  js.to_file File.join(ROOT, 'target', "slimTrack-#{[js.profile,js.version].compact.join('-')}.js")
  
  js.minify!
  js.to_file File.join(ROOT, 'target', "slimTrack-#{[js.profile,js.version].compact.join('-')}.min.js")
  
  puts ''
  puts 'Files:'
  Dir.glob(File.join(ROOT, 'target', '*.js')) { |filename|
    puts "  #{filename.sub(ROOT, '')}\t#{File.stat(filename).size} bytes"
  }
  
  puts ''
end



desc "Deploy JavaScript (to Maven?)"
task :deploy => :build do
  puts "DEPLOY\n"
  
  system "zip #{File.join(ROOT, 'target', 'tracking.zip')} #{Dir.glob(File.join(ROOT, 'target', '*.js')).join(' ')}"
  system "cp #{File.join(ROOT, 'target', 'tracking.zip')} #{File.join(ROOT, 'target', 'tracking.jar')}"
  
  puts ''
  puts 'Files:'
  Dir.glob(File.join(ROOT, 'target', '*')) { |filename|
    puts "  #{filename.sub(ROOT, '')}\t#{File.stat(filename).size} bytes"
  }
  
  puts ''
end

task :default => 'versions'
