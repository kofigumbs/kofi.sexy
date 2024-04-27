require "jekyll"

class Generator < Jekyll::Generator
  priority :highest

  def generate(site)
    # Load profile.jpg as base64 for use in the favicon
    site.data['profile_base64'] = %x(cat _www/images/profile.jpg | base64)

    # Mix external posts (from _config.yml) into feed
    posts = site.collections["posts"]
    site.config["external_posts"].each do |yaml|
      doc = ExternalPost.new(yaml["permalink"], site: site, collection: posts)
      doc.data.merge!(yaml, { "collection" => "posts", "draft" => false, "external" => true })
      posts.docs << doc
    end
  end
end

class ExternalPost < Jekyll::Document
  def initialize(url, options)
    super("", options)
    @url = url
  end

  def write(*)
  end
end
