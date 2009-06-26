$:.unshift File.dirname(__FILE__) + '/sinatra/lib'
require 'sinatra'
 
Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production
)

log = File.new(File.join( File.dirname(__FILE__), '..', 'log', 'sinatra.log'), "a")
$stdout.reopen(log)
$stderr.reopen(log)
 
require 'marley'
run Sinatra.application