require "jekyll"

class Generator < Jekyll::Generator
  priority :highest

  def generate(site)
    # Load profile.jpg as base64 for use in the favicon
    site.data['profile_base64'] = %x(cat _www/images/profile.jpg | base64)

    # Mix external posts (from _config.yml) into feed
    posts = site.collections["posts"]
    site.config["external_posts"].each do |yaml|
      doc = ExternalPost.new yaml["url"], site: site, collection: posts
      doc.data["permalink"]  = yaml["url"]
      doc.data["title"]      = yaml["title"]
      doc.data["image"]      = yaml["image"]
      doc.data["date"]       = yaml["date"]
      doc.data["categories"] = yaml["categories"]
      doc.data["collection"] = "posts"
      doc.data["draft"]      = false
      doc.data["external"]   = true
      posts.docs << doc
    end
  end
end

class ExternalPost < Jekyll::Document
  def initialize(url, options)
    super("", options)
    @url = url
    @content = "<a href='#{url}'>#{url}</a>"
  end

  def write(*_)
  end
end
