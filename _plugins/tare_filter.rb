require 'jekyll'
require 'tare'

module Jekyll::TareFilter
  def tare input
    Tare::html input
  end
end

Liquid::Template.register_filter(Jekyll::TareFilter)
