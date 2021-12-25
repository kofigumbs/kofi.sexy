require "jekyll"

module Jekyll
  class LogoGenerator < Generator
    def generate(site)
      site.data['logo_base64'] = %x(cat _www/images/profile.jpg | base64 | tr -d '\r\n')
    end
  end
end
