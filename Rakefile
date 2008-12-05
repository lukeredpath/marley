require 'rubygems'
require 'activerecord'
require 'rake'
require 'rake/testtask'
require 'ftools'

MARLEY_ROOT = '.'

%w{configuration post comment}.each { |f| require File.join(MARLEY_ROOT, 'app', 'marley', f) }

include Marley::Configuration

task :default => 'app:start'

namespace :app do

  desc "Install the fresh application"
  task :install do
    Rake::Task['app:install:create_data_directory'].invoke
    Rake::Task['app:install:create_database_for_comments'].invoke
    Rake::Task['app:install:create_sample_article'].invoke
    Rake::Task['app:install:create_sample_comment'].invoke
    puts "* Starting application in development mode"
    Rake::Task['app:start'].invoke
  end
  namespace :install do
    task :create_data_directory do
      puts "* Creating data directory in " + marley_config.data_directory
      FileUtils.mkdir_p( marley_config.data_directory )
    end
    desc "Create database for comments"
    task :create_database_for_comments do
      puts "* Creating comments SQLite database in #{comments_database_path}"
      ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => comments_database_path)
      load(File.join( MARLEY_ROOT, 'config', 'db_create_comments.rb' ))
    end
    task :create_sample_article do
      puts "* Creating sample article"
      FileUtils.cp_r(File.join(MARLEY_ROOT, 'app', 'test', 'fixtures', '001-test-article-one'), marley_config.data_directory)
    end
    task :create_sample_comment do
      require 'vendor/akismetor'
      puts "* Creating sample comment"
      Marley::Comment.create( :author  => 'John Doe',
                              :email   => 'john@example.com',
                              :body    => 'Lorem ipsum dolor sit amet',
                              :post_id => 'test-article' )
    end
  end

  desc 'Start application in development'
  task :start do
    exec "ruby app/marley.rb"
  end

  desc "Run tests for the application"
  Rake::TestTask.new(:test) do |t|
    t.libs << 'app/marley'
    t.pattern = 'app/test/**/*_test.rb'
    t.verbose = true
  end
  
end

namespace :data do
  
  task :sync do
    # TODO : use Git
    exec "cap data:sync"
  end
    
end

namespace :server do
  
  task :start do
    exec "cd app; thin -R rackup.ru -d -P ../tmp/pids/thin.pid -l ../log/production.log -e production -p 4500 start"
  end
  
  task :stop do
    exec "thin stop"
  end
  
  task :restart do 
    exec "thin restart"
  end
  
end


namespace :generate do
  
  task :post do
    if article_name = ENV['name']
      article_token = article_name.downcase.squeeze(' ').gsub(/\s/, '-')
      article_index = Dir["#{marley_config.data_directory}/*"].select { |node| 
        File.directory?(node) 
      }.map { |dir| dir.match(/[0-9]+/)[0] }.sort.last.succ rescue "001"
      article_dir = "#{article_index}-#{article_token}"
      FileUtils.mkdir(File.join(marley_config.data_directory, article_dir))
      File.open(File.join(marley_config.data_directory, article_dir, "article.txt"), 'w') do |io|
        io << "# #{article_name}\n"
      end
    else
      puts "You must specify an article name using name='My article name.'"
      exit 1
    end
  end
  
end
