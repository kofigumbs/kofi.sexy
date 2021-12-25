require "jekyll"

module Jekyll
  class ExternalPostsGenerator < Generator
    safe true
    priority :highest

    def generate(site)
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
        posts.docs << doc
      end
    end
  end

  class ExternalPost < Document
    def initialize(url, options)
      super("", options)
      @url = url
      @content = "<a href='#{url}'>#{url}</a>"
    end

    def write(*_)
    end
  end
end
