module Marley
  
  class Repository
    attr_reader :data_directory
    
    def initialize(data_directory)
      @data_directory = data_directory
    end
    
    def all
      Dir[File.join(@data_directory, '*')].map { |file|
        next unless File.extname(file) =~ /txt|markdown|textile/
        Marley::Post.open(file)
      }.compact
    end
    
    def find(id)
      if file = Dir[File.join(@data_directory, '*')].find { |dir| dir =~ Regexp.new(id) }
        Marley::Post.open(file)
      end
    end
    
    class << self
      attr_accessor :default_data_directory
      
      def default
        return nil unless self.default_data_directory
        @default_repository ||= new(self.default_data_directory)
      end
    end
  end
  
end
