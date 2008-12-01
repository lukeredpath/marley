require 'date'
require File.join(File.dirname(__FILE__), 'repository')
require File.join(File.dirname(__FILE__), 'post_builder')

module Marley

  # = Articles
  # Data source is Marley::Configuration::DATA_DIRECTORY (set in <tt>config.yml</tt>)
  class Post
    
    attr_reader :id, :title, :perex, :body, :published_on, :updated_on, :published, :categories, :format
    
    # comments are referenced via +has_many+ in Comment
    
    def initialize(options={})
      options.each_pair { |key, value| instance_variable_set("@#{key}", value) if self.respond_to? key }
    end
  
    class << self

      def all(options={})
        self.find_all options.merge(:draft => true)
      end
    
      def published(options={})
        self.find_all options.merge(:draft => false)
      end
  
      def [](id, options={})
        self.find_one(id, options)
      end
      alias :find :[] # For +belongs_to+ in Comment

    end

    def permalink
      "/#{id}.html"
    end
    
    def comments
      @comments ||= Marley::Comment.find_all_by_post_id(self.id)
    end
    
    def body_html
      @body_html ||= RDiscount::new(self.body).to_html
    end
            
    private
    
    def self.repository
      @repository ||= Repository.new(Configuration::DATA_DIRECTORY)
    end
    
    def self.find_all(options={})
      options[:except] ||= ['body', 'body_html']
      posts = repository.all_articles.map do |file|
        PostBuilder.new(File.dirname(file)).build
      end
      return posts.reverse
    end
    
    def self.find_one(id, options={})
      options.merge!(:draft => true)
      if file = repository.article_with_id(id)
        PostBuilder.new(File.dirname(file)).build
      end
    end  
  end

end
