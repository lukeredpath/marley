require 'date'
require 'rdiscount'
require 'redcloth'
require File.join(File.dirname(__FILE__), 'repository')
require File.join(File.dirname(__FILE__), 'post_builder')
require 'digest/md5'

module Marley

  class Post
    include Comparable
    
    def self.parse(id, post_data, format = :plain)
      new(id, post_data.split('---').last.strip, YAML.load(post_data), format)
    end
    
    def self.open(path_to_file, options={})
      options = {:convert_underscores => false}.merge(options)
      post = nil
      File.open(path_to_file, 'r') do |io|
        extension = File.extname(path_to_file)
        file_name = File.basename(path_to_file, extension).gsub(/^[0-9]+\-/, '')
        file_name.gsub!(/_/, '-') if options[:convert_underscores]
        post = self.parse(file_name, io.read, extension[1..-1].to_sym)
      end
      return post
    end
    
    attr_reader :metadata, :body, :id
    attr_accessor :format
    
    def initialize(id, body, metadata = {}, format = :plain)
      @id = id
      @body = body
      @metadata = metadata
      self.format = format
    end
    
    def title
      @metadata[:title]
    end
    
    def published_on
      DateTime.parse(@metadata[:published_on])
    end
    
    def to_html
      parsers[format].call(@body)
    end
    
    def format=(new_format)
      if parsers.has_key?(new_format)
        @format = new_format
      else
        @format = :plain
      end
    end

    def permalink
      "/#{id}.html"
    end
    
    def hash
      Digest::MD5.hexdigest("#{id}#{body[0..20]}")
    end
    
    def ==(other_post)
      hash == other_post.hash
    end
            
    private
    
    def parsers
      @parsers ||= {
        :plain    => proc{ |body| body },
        :textile  => proc{ |body| RedCloth.new(body).to_html },
        :markdown => proc{ |body| RDiscount.new(body).to_html.strip }
      }
    end
  end

end
