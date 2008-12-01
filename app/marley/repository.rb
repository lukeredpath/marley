module Marley
  
  class Repository
    def initialize(data_directory)
      @data_directory = data_directory
    end
    
    def all_articles(options={})
      options = {:draft => false}.merge(options)
      Dir[File.join(@data_directory, '*')].map { |directory|
        next if directory =~ /.draft/ && !options[:draft]
        Dir[File.join(directory, '*.txt')].first
      }.compact
    end
    
    def article_with_id(id)
      Dir[File.join(@data_directory, '*')].select { |dir| dir =~ Regexp.new(id) }.map { |directory|
        Dir[File.join(directory, '*.txt')].first
      }.compact.first
    end
  end
  
end
