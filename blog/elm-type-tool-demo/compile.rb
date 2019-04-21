#!/usr/bin/env ruby

require "pathname"

here   = Pathname.new(__FILE__).parent
output = here.join("elm-snapshot")
readme = here.join("README.md")

File.open(output, "wb") do |program|
  File.new(readme).each_line do |line|
    if    line.strip == "```ruby" then @code_block = true
    elsif line.strip == "```"     then @code_block = false
    elsif @code_block             then program.puts(line)
    end
  end
end

system "chmod +x #{output}"
