module Marley
  class PostBuilder
    def initialize(directory)
      @directory = directory
    end
    
    def build
      post_data = {}
      post_data.merge!({
        :id           => article_id,
        :title        => meta_data[:title],
        :perex        => raw_perex,
        :body         => raw_article_body,
        :published_on => article_publish_data,
        :updated_on   => File.mtime(article_path),
        :published    => !draft?,
        :format       => meta_data[:format] || :markdown,
        :categories   => meta_data[:categories] || []
      })
      return Post.new(post_data)
    end
    
    private
      PEREX_PATTERN = /^([^\#\n]+\n)$/
    
      def meta_data
        raise "Cannot find meta file" unless File.exist?(meta_data_path)
        return YAML.load(File.read(meta_data_path))
      end
      
      def raw_perex
        raise "Cannot find article file" unless File.exist?(article_path)
        File.read(article_path).scan(PEREX_PATTERN).first.to_s.strip
      end
      
      def raw_article_body
        raise "Cannot find article file" unless File.exist?(article_path)
        return File.read(article_path).sub(PEREX_PATTERN, '').strip
      end
      
      def meta_data_path
        File.join(@directory, 'meta.yml')
      end
      
      def article_path
        File.join(@directory, 'article.txt')
      end
      
      def article_id
        dirname = @directory.split('/').last
        dirname.sub(/^\d{0,4}-{0,1}(.*)$/, '\1').sub(/\.draft$/, '')
      end
      
      def article_publish_data
        DateTime.parse(meta_data[:published_on]) rescue File.mtime(@directory)
      end
      
      def draft?
        @directory.match(/\.draft$/)
      end
  end
end