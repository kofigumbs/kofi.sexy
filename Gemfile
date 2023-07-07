source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "jekyll"
gem "tare", github: "kofigumbs/tare", ref: "bfd61db"

group :jekyll_plugins do
  gem "jekyll-commonmark"
  gem "jekyll-feed"
  gem "jekyll-seo-tag"
end

group :development do
  gem "webrick", "~> 1.8"
end
