require "jekyll"
require "mp3info"

class Generator < Jekyll::Generator
  priority :highest

  def generate(site)
    # Load profile.jpg as base64 for use in the favicon
    site.data['profile_base64'] = %x(cat _www/images/profile.jpg | base64 | tr -d '\r\n')

    # Set the correct MP3 tag metadata for each track
    Dir.glob("_www/music/*.mp3").each do |file|
      Mp3Info.open(file, parse_tags: true, parse_mp3: false) do |mp3|
        mp3.tag.title  = file.match(/-(.+)\.mp3/)[1]
        mp3.tag.album  = mp3.tag.title
        mp3.tag.artist = "Kofi Gumbs"
      end
    end

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
