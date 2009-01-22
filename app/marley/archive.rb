module Marley
  
  class Archive
    def initialize(posts)
      @posts = posts
    end
    
    def posts_indexed_by_month_and_year
      @posts.inject({}) do |index, post|
        (index[post.month_and_year] ||= []) << post
        index
      end
    end
  end
  
end