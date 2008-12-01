require File.join(File.dirname(__FILE__), 'test_helper')
require 'repository'

class RepositoryTest < Test::Unit::TestCase
  
  context "A repository" do
    setup do
      @repository = Marley::Repository.new(FIXTURES_DIRECTORY)
    end

    should "should return all non-draft articles" do
      expected = [
        File.join(FIXTURES_DIRECTORY, '001-test-article-one', 'test-article.txt'),
        File.join(FIXTURES_DIRECTORY, '002-test-article-two', 'test-article.txt')
      ]
      assert_equal expected, @repository.all_articles
    end
    
    should "ignore drafts by default when fetching all articles" do
      draft_directory = File.join(FIXTURES_DIRECTORY, '003-test-article-three.draft')
      
      begin
        FileUtils.mkdir(draft_directory)
        FileUtils.touch(File.join(draft_directory, 'article.txt'))
      
        expected = [
          File.join(FIXTURES_DIRECTORY, '001-test-article-one', 'test-article.txt'),
          File.join(FIXTURES_DIRECTORY, '002-test-article-two', 'test-article.txt')
        ]
        assert_equal expected, @repository.all_articles
      ensure
        FileUtils.rm_rf(draft_directory)
      end
    end
    
    should "return drafts if requested when fetching all articles" do
      draft_directory = File.join(FIXTURES_DIRECTORY, '003-test-article-three.draft')
      
      begin
        FileUtils.mkdir(draft_directory)
        FileUtils.touch(File.join(draft_directory, 'article.txt'))
      
        expected = [
          File.join(FIXTURES_DIRECTORY, '001-test-article-one', 'test-article.txt'),
          File.join(FIXTURES_DIRECTORY, '002-test-article-two', 'test-article.txt'),
          File.join(FIXTURES_DIRECTORY, '003-test-article-three.draft', 'article.txt')
        ]
        assert_equal expected, @repository.all_articles(:draft => true)
      ensure
        FileUtils.rm_rf(draft_directory)
      end
    end
    
    should "return a single article by ID" do
      expected = File.join(FIXTURES_DIRECTORY, '002-test-article-two', 'test-article.txt')
      assert_equal expected, @repository.article_with_id('test-article-two')
    end
  end
  
end