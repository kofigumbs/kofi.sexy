require "jekyll"
module Jekyll::LogoTriangleFilter
  def logo_triangle(s, cx, cy)
    d = s/2.0
    r = d/Math.sqrt(3)
    "M #{cx - 2*r} #{cy} l #{3*r} #{-d} l 0 #{s} Z"
  end
end
Liquid::Template.register_filter(Jekyll::LogoTriangleFilter)
