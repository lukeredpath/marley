require File.join(File.dirname(__FILE__), 'test_helper')
require 'repository'
require 'post'

class RepositoryTest < Test::Unit::TestCase
  
  context "A repository" do
    setup do
      @repository = Marley::Repository.new(FIXTURES_DIRECTORY)
    end

    should "should return all non-draft articles" do
      expected = [
        Marley::Post.open(File.join(FIXTURES_DIRECTORY, '001-another-post.textile')),
        Marley::Post.open(File.join(FIXTURES_DIRECTORY, 'example_post.textile'))
      ]
      assert_equal expected, @repository.all
    end
    
    should "return a single article by ID" do
      expected = Marley::Post.open(File.join(FIXTURES_DIRECTORY, 'example_post.textile'))
      assert_equal expected, @repository.find('example_post')
    end
    
    should "return nil for a non-existent article" do
      assert_nil @repository.find('doesnt-exist')
    end
  end
  
end