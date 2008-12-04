xml.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
xml.feed :'xml:lang' => 'en-US', :xmlns => 'http://www.w3.org/2005/Atom' do
  xml.id absolute_url
  xml.link :type => 'text/html', :href => absolute_url, :rel => 'alternate'
  xml.link :type => 'application/atom+xml', :href => absolute_url("/feed"), :rel => 'self'
  xml.title CONFIG['blog']['title']
  xml.subtitle "#{h(hostname)}"
  xml.updated(@posts.first ? rfc_date(@posts.first.updated_on) : rfc_date(Time.now.utc))
  @posts.each do |post|
    xml.entry do |entry|
      entry.id absolute_url("#{hostname}/#{post.id}.html")
      entry.link :type => 'text/html', :href => absolute_url("/#{post.id}.html"), :rel => 'alternate'
      entry.updated rfc_date(post.updated_on)
      entry.title post.title
      entry.content post.body_html,  :type => 'html'
      entry.author do |author|
        author.name  CONFIG['blog']['author'] || hostname
        author.email(CONFIG['blog']['email'])  if CONFIG['blog']['email']
      end
    end
  end
end
