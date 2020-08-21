require "jekyll"
require "mp3info"

module Jekyll
  class Mp3TagsGenerator < Generator
    safe false

    def generate(site)
      Dir.glob("_www/music/*.mp3").each do |file|
        Mp3Info.open(file, parse_tags: true, parse_mp3: false) do |mp3|
          mp3.tag.title  = file.match(/-(.+)\.mp3/)[1]
          mp3.tag.album  = mp3.tag.title
          mp3.tag.artist = "Kofi Gumbs"
        end
      end
    end
  end
end
