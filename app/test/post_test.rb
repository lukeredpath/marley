require File.join(File.dirname(__FILE__), 'test_helper')
require 'post'

class PostTest < Test::Unit::TestCase
  
  context "A simple post, without a specified format" do
    setup do
      @post = Marley::Post.parse 'test-article-one', <<-eot
---
:title: A test post
:published_on: Fri Jul 28 17:00:00 UTC 2006
---
This is a simple *post* without any special formatting.
      eot
    end

    should "return article metadata as a hash" do
      expected = {:title => 'A test post', :published_on => "Fri Jul 28 17:00:00 UTC 2006"}
      assert_equal expected, @post.metadata
    end
    
    should "return article id" do
      assert_equal 'test-article-one', @post.id
    end
    
    should "return article body" do
      assert_equal "This is a simple *post* without any special formatting.", @post.body
    end
    
    should "return the article title" do
      assert_equal 'A test post', @post.title
    end
    
    should "return the published_on date" do
      assert_equal DateTime.parse("Fri Jul 28 17:00:00 UTC 2006"), @post.published_on
    end
    
    should "return the post body unchanged when converted to HTML" do
      assert_equal @post.body, @post.to_html
    end
  end
  
  context "A textile-formatted post" do
    setup do
      @post = Marley::Post.parse 'test-article-two', <<-eot
---
:title: A textile post
---
This is a *textile* post.
      eot
      @post.format = :textile
    end

    should "return textile-formatted text as HTML" do
      assert_equal "<p>This is a <strong>textile</strong> post.</p>", @post.to_html
    end
  end
    
  context "A markdown-formatted post" do
    setup do
      @post = Marley::Post.parse 'test-article-three', <<-eot
---
:title: A markdown post
---
This is a _markdown_ post.
      eot
      @post.format = :markdown
    end

    should "return markdown-formatted text a HTML" do
      assert_equal "<p>This is a <em>markdown</em> post.</p>", @post.to_html
    end
  end
  
  context "A post, in general" do
    setup do
      @post = Marley::Post.new('test-article-four', "this is a post")
    end

    should "use :plain format if unspecified format is given" do
      @post.format = :doohickey
      assert_equal :plain, @post.format
    end
    
    should "equal another post with the same id and body" do
      another_post = Marley::Post.new(@post.id, @post.body)
      assert_equal @post, another_post
    end
  end
  
  context "A post, read from a file" do
    setup do
      @post = Marley::Post.open(File.join(File.dirname(__FILE__), *%w[fixtures example_post.textile]))
    end

    should "parse the contents of the file" do
      assert_equal "This is a *textile* post.", @post.body
      assert_equal "A textile post", @post.title
    end
    
    should "use the file extension as the post format" do
      assert_equal :textile, @post.format
    end
    
    should "use the file name as the post id" do
      assert_equal 'example_post', @post.id
    end
  end
  
  context "Reading a post from a file" do
    should "convert underscores to hyphens in file name if option specified" do
      file = File.join(File.dirname(__FILE__), *%w[fixtures example_post.textile])
      post = Marley::Post.open(file, :convert_underscores => true)
      assert_equal 'example-post', post.id
    end
    
    should "ignore any numeric prefix in the file name" do
      file = File.join(File.dirname(__FILE__), *%w[fixtures 001-another-post.textile])
      post = Marley::Post.open(file, :convert_underscores => true)
      assert_equal 'another-post', post.id
    end
  end
  
  context "A collection of posts" do
    setup do
      @posts = [
        @post_one   = Marley::Post.new('post-one', 'body', :published_on => '22-01-2009'),
        @post_two   = Marley::Post.new('post-two', 'body', :published_on => '10-01-2009'),
        @post_three = Marley::Post.new('post-thr', 'body', :published_on => '15-01-2009')
      ]
    end

    should "be be sortable by their published_on date, most recent first" do
      assert_equal [@post_one, @post_three, @post_two], @posts.sort
    end
  end

end

