require 'post'

module Marley
  
  class Repository
    def initialize(data_directory)
      @data_directory = data_directory
    end
    
    def all
      Dir[File.join(@data_directory, '*')].map { |file|
        Marley::Post.open(file)
      }
    end
    
    def find(id)
      if file = Dir[File.join(@data_directory, '*')].find { |dir| dir =~ Regexp.new(id) }
        Marley::Post.open(file)
      end
    end
  end
  
end
