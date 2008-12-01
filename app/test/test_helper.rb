require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w[.. marley]))
FIXTURES_DIRECTORY = File.join(File.dirname(__FILE__), 'fixtures')