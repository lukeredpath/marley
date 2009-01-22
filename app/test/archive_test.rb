require File.join(File.dirname(__FILE__), 'test_helper')
require 'archive'
require 'post'

class ArchiveTest < Test::Unit::TestCase
  
  context "An archive of posts" do
    setup do
      @post_one   = Marley::Post.new('post-one', 'body', {:published_on => '05 Jan 2009'})
      @post_two   = Marley::Post.new('post-two', 'body', {:published_on => '01 Jan 2009'})
      @post_three = Marley::Post.new('post-thr', 'body', {:published_on => '14 Dec 2008'})
      @post_four  = Marley::Post.new('post-for', 'body', {:published_on => '22 Nov 2008'})
      
      @archive = Marley::Archive.new([@post_one, @post_two, @post_three, @post_four])
    end

    should "return posts as a hash indexed by month and year" do
      expected = {
        [1,  2009] => [@post_one, @post_two],
        [12, 2008] => [@post_three],
        [11, 2008] => [@post_four]
      }
      assert_equal expected, @archive.posts_indexed_by_month_and_year
    end
  end
  
end