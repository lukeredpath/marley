xml.instruct!  
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do  
  xml.url do
    xml.loc absolute_url("/")
    xml.lastmod @posts.first.published_on.xmlschema
  end
  xml.url do
    xml.loc absolute_url("/archive")
    xml.lastmod @posts.first.published_on.xmlschema
  end
  @posts.each do |post|
    xml.url do  
      xml.loc permalink(post)
      xml.lastmod post.updated_on.xmlschema  
    end  
  end  
end