xml.instruct! :xml, :version => '1.0'
xml.feed :'xml:lang' => 'en-US', :xmlns => 'http://www.w3.org/2005/Atom' do
  xml.id absolute_url("/feed/comments")
  xml.link :type => 'text/html', :href => absolute_url, :rel => 'alternate'
  xml.link :type => 'application/atom+xml', :href => absolute_url("/feed/comments"), :rel => 'self'
  xml.title "Comments for #{marley_config.blog.title}"
  xml.subtitle "#{h(hostname)}"
  xml.updated(@comments.first ? rfc_date(@comments.first.created_at) : rfc_date(Time.now.utc)) if @comments.first
  @comments.each_with_index do |comment, index|
    xml.entry do |entry|
      entry.id absolute_url("/#{comment.post.id}.html#comment_#{index}")
      xml.updated rfc_date(comment.created_at)
      entry.link :type => 'text/html', :href => absolute_url("/#{comment.post.id}.html#comment_#{index}"), :rel => 'alternate'
      entry.title "Comment on #{comment.post.title} by #{h comment.author}"
      entry.content h(comment.body), :type => 'html'
      entry.author do |author|
        author.name  comment.author
        author.uri(comment.url) if comment.url =~ /^[a-z]/
      end
    end
  end
end
