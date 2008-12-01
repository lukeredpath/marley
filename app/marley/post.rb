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
    
    # Extracts post information from the directory name, file contents, modification time, etc
    # Returns hash which can be passed to <tt>Marley::Post.new()</tt>
    # Extracted attributes can be configured with <tt>:except</tt> and <tt>:only</tt> options
    def self.extract_post_info_from(file, options={})
      raise ArgumentError, "#{file} is not a readable file" unless File.exist?(file) and File.readable?(file)
      options[:except] ||= []
      options[:only]   ||= Marley::Post.instance_methods # FIXME: Refaktorovat!!
      dirname       = File.dirname(file).split('/').last
      file_content  = File.read(file)
      meta_content  = file_content.slice!( self.regexp[:meta] )
      body          = file_content.sub( self.regexp[:title], '').sub( self.regexp[:perex], '').strip
      post          = Hash.new

      post[:id]           = dirname.sub(/^\d{0,4}-{0,1}(.*)$/, '\1').sub(/\.draft$/, '')
      post[:title], post[:published_on] = file_content.scan( self.regexp[:title_with_date] ).first
      post[:title]        = file_content.scan( self.regexp[:title] ).first.to_s.strip if post[:title].nil?
      post[:published_on] = DateTime.parse( post[:published_on] ) rescue File.mtime( File.dirname(file) )

      post[:perex]        = file_content.scan( self.regexp[:perex] ).first.to_s.strip unless options[:except].include? 'perex' or
                                                                                      not options[:only].include? 'perex'
      post[:body]         = body                                                      unless options[:except].include? 'body' or
                                                                                      not options[:only].include? 'body'
      post[:body_html]    = RDiscount::new( body ).to_html                            unless options[:except].include? 'body_html' or
                                                                                      not options[:only].include? 'body_html'
      post[:meta]         = ( meta_content ) ? YAML::load( meta_content.scan( self.regexp[:meta]).to_s ) : 
                                               nil unless options[:except].include? 'meta' or not options[:only].include? 'meta'
                                                                                      not options[:only].include? 'published_on'
      post[:updated_on]   = File.mtime( file )                                        unless options[:except].include? 'updated_on' or
                                                                                      not options[:only].include? 'updated_on'
      post[:published]    = !dirname.match(/\.draft$/)                                unless options[:except].include? 'published' or
                                                                                      not options[:only].include? 'published'
      return post
    end
    
    def self.regexp
      { :id    => /^\d{0,4}-{0,1}(.*)$/,
        :title => /^#\s*(.*)\s+$/,
        :title_with_date => /^#\s*(.*)\s+\(([0-9\/]+)\)$/,
        :published_on => /.*\s+\(([0-9\/]+)\)$/,
        :perex => /^([^\#\n]+\n)$/, 
        :meta  => /^\{\{\n(.*)\}\}\n$/mi # Multiline Regexp 
      } 
    end
  
  end

end
