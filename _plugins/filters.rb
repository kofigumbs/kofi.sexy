require 'jekyll'
require 'tare'

module Filters
  def tare input
    Tare::html input
  end
end

Liquid::Template.register_filter Filters
