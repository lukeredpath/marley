require 'rubygems'
require 'ftools'           # ... we wanna access the filesystem ...
require 'yaml'             # ... use YAML for configs and stuff ...
require 'sinatra'          # ... Classy web-development dressed in DSL, http://sinatrarb.heroku.com
require 'activerecord'     # ... or Datamapper? What? :)

# ... or alternatively, run Sinatra on edge ...
# $:.unshift File.dirname(__FILE__) + 'vendor/sinatra/lib'
# require 'sinatra'

MARLEY_ROOT = File.join(File.dirname(__FILE__), '..') unless defined?(MARLEY_ROOT)

$:.unshift File.join(MARLEY_ROOT, 'vendor')
$:.unshift File.join(MARLEY_ROOT, 'vendor/simpleconfig-1.0.1/lib')
$:.unshift File.join(MARLEY_ROOT, 'vendor/norman-disqus/lib')

require 'disqus'

$logger = Logger.new(File.join(MARLEY_ROOT, 'log', 'marley.log'))

# -----------------------------------------------------------------------------

# FIXME : There must be a clean way to do this :)
req_or_load = (Sinatra.env == :development) ? :load : :require
%w{configuration.rb post.rb archive.rb}.each do |f|
  send(req_or_load, File.join(File.dirname(__FILE__), 'marley', f) )
end

# -----------------------------------------------------------------------------

include Marley::Configuration

configure do
  $logger.level = Logger::DEBUG
  set_options :views => marley_theme_directory
  Marley::Repository.default_data_directory = marley_config.data_directory
  Disqus.defaults[:account] = marley_config.disqus_account
  Disqus.defaults[:api_key] = marley_config.disqus_api_key
end

configure :production do
  $logger.level = Logger::INFO
  not_found { not_found }
  error     { error }
end

helpers do
  
  include Rack::Utils
  alias_method :h, :escape_html
  
  def local?
    hostname =~ /.local|localhost/
  end

  def markup(string)
    RDiscount::new(string).to_html
  end
  
  def human_date(datetime)
    datetime.strftime('%d|%m|%Y').gsub(/ 0(\d{1})/, ' \1')
  end

  def rfc_date(datetime)
    datetime.strftime("%Y-%m-%dT%H:%M:%SZ") # 2003-12-13T18:30:02Z
  end

  def hostname
    (request.env['HTTP_X_FORWARDED_SERVER'] =~ /[a-z]*/) ? request.env['HTTP_X_FORWARDED_SERVER'] : request.env['HTTP_HOST']
  end
  
  def absolute_url(path = "")
    "http://#{hostname}#{relative_path(path)}".strip
  end
  
  def relative_path(path)
    "#{marley_config.base_path}#{path}"
  end

  def not_found
    File.read( File.join( File.dirname(__FILE__), 'public', '404.html') )
  end

  def error
    File.read( File.join( File.dirname(__FILE__), 'public', '500.html') )
  end
  
  def permalink(post)
    relative_path("/#{post.id}.html")
  end
  
  def config
    Marley::Configuration.config
  end

end

# -----------------------------------------------------------------------------

["/", ""].each do |root|
  get root do
    @posts = Marley::Repository.default.all.sort.first(10)
    @page_title = marley_config.blog.title
    erb :index
  end
end

get "/archive" do
  @posts = Marley::Repository.default.all.sort
  @posts_index = Marley::Archive.new(@posts).posts_indexed_by_month_and_year
  @page_title = "Archives of #{marley_config.blog.title}"
  erb :archive
end

get '/feed' do
  @posts = Marley::Repository.default.all.sort
  last_modified( @posts.first.updated_on )
  builder :index
end

get '/:post_id.html' do
  @post = Marley::Repository.default.find(params[:post_id])
  throw :halt, [404, not_found ] unless @post
  @page_title = "#{@post.title} #{marley_config.blog.name}"
  erb :post 
end

get '/theme/stylesheets/:stylesheet.css' do
  stylesheet_path = marley_theme_stylesheet_path(params[:stylesheet])
  if File.exist?(stylesheet_path)
    send_file stylesheet_path, :type => 'text/css', :disposition => 'inline', :stream => false
  else
    throw :halt, [404, not_found]
  end
end

post '/sync' do
  throw :halt, 404 and return unless marley_config.github_token
  unless params[:token] && params[:token] == marley_config.github_token
    throw :halt, [500, "You did wrong.\n"] and return
  else
    # Synchronize articles in data directory to Github repo
    system "cd #{Marley::Repository.default.data_directory}; git pull origin master"
  end
end

get '/about' do
  "<p style=\"font-family:sans-serif\">I'm running on Sinatra version " + Sinatra::VERSION + '</p>'
end

get "/sitemap.xml" do
  @posts = Marley::Repository.default.all.sort
  builder :sitemap
end

# -----------------------------------------------------------------------------