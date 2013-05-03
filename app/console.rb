require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'analytics')
require File.join(ROOT, 'lib', 'capi')
require 'irb'; require 'irb/completion'
include FT::Analytics 

puts 'Scope: FT::Analytics'

IRB.start