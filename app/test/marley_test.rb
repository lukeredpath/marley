require File.join(File.dirname(__FILE__), 'test_helper')
require 'rack'
require 'sinatra'
require 'sinatra/test/unit'

# Require application file
require File.join(File.dirname(__FILE__), *%w[.. marley])

TEST_DATABASE = File.join(FIXTURES_DIRECTORY, 'test.db')

# Redefine database with comments for tests
module Marley
  class Comment < ActiveRecord::Base
    ActiveRecord::Base.establish_connection( 
      :adapter => 'sqlite3', 
      :database => TEST_DATABASE
    )
  end
end

# "Stub" anti-spam library
class Akismetor
  def self.spam?(attributes)
    rand > 0.5 ? true : false
  end
end


# Setup fresh comments table
File.delete(TEST_DATABASE) if File.exists?(TEST_DATABASE)
ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => TEST_DATABASE)
load File.join(MARLEY_ROOT, 'config', 'db_create_comments.rb' )


class MarleyTest < Test::Unit::TestCase
  include Marley::Configuration

  configure do
    marley_config.stubs(:theme).returns("default")
    set_options :views => marley_theme_directory
  end
  
  def setup
    Marley::Post.data_directory = File.join(MARLEY_ROOT, 'app', 'test', 'fixtures')
  end

  def test_should_show_index_page
    get_it '/'
    assert @response.status == 200
  end

  def test_should_show_article_page
    get_it '/test-article-one.html'
    assert @response.status == 200
    assert @response.body =~ Regexp.new( 
           Regexp.escape("<h1>\n    This is the test article one\n    <span class=\"meta\">\n      23|12|2050") ),
           "HTML should contain valid <h1> title for post"
  end

  def test_should_send_404
    get_it '/i-am-not-here.html'
    assert @response.status == 404
  end

  def test_should_create_comment
    comment_count = Marley::Comment.count
    post_it '/test-article/comments', default_comment_attributes
    assert @response.status == 302
    assert Marley::Comment.count == comment_count + 1
  end

  def test_should_fix_url_on_comment_create
    post_it '/test-article/comments', default_comment_attributes.merge(:url => 'www.example.com')
    assert_equal 'http://www.example.com', Marley::Comment.last.url
  end

  def test_should_NOT_fix_blank_url_on_comment_create
    comment_count = Marley::Comment.count
    post_it '/test-article/comments', default_comment_attributes.merge(:url => '')
    assert_equal '', Marley::Comment.last.url
  end

  def test_should_show_feed_for_index
    get_it '/feed'
    assert @response.status == 200
  end

  def test_should_show_feed_for_article
    get_it '/test-article/feed'
    assert @response.status == 200
  end

  def test_should_show_feed_for_combined_comments
    get_it '/feed/comments'
    assert @response.status == 200
  end

  def test_articles_should_have_proper_published_on_dates
    get_it '/'
    #p @response.body
    assert @response.status == 200
    assert @response.body =~ Regexp.new(Regexp.escape("<small>23|12|2050 &mdash;</small>")),
                             "HTML should contain proper date for post one"
    assert @response.body =~ Regexp.new(Regexp.escape("<small>#{File.mtime(File.join(FIXTURES_DIRECTORY, '002-test-article-two')).strftime('%d|%m|%Y')} &mdash;</small>")),
                             "HTML should contain proper date for post two"
  end

  private

  def default_comment_attributes
    { :ip => "127.0.0.1",
      :user_agent => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_4; en-us)",
      :body => "Testing comments...",
      :post_id => "test-article",
      :url => "www.example.com",
      :author => 'Tester',
      :email => "tester@localhost" }
  end

end