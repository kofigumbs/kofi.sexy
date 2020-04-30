require "jekyll"
module Jekyll::CharactersFilter
  def characters(input); input.split ""; end
end
Liquid::Template.register_filter(Jekyll::CharactersFilter)
