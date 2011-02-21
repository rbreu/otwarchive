#!/usr/bin/env ruby

# This is and evil workaround for the tr8n plugin being reloaded on
# every request while the initializer doesn't (result: configuration
# gets overwritten by default values after the very first request)
#
# I couldn't prevent tr8n from reloading. :(
#
# So copy&paste initializer stuff into the plugin code. /o\

src = "config/initializers/gem-plugin_config/tr8n.rb"
dst = "vendor/plugins/tr8n/lib/tr8n/config.rb"

puts "Opening file #{src}"
conf = File.read(src)

conf.match /(    # BEGIN EVIL HACK COMMENT DON'T REMOVE.*?# END EVIL HACK COMMENT DON'T REMOVE)/m
  
conf = $1

puts "Found config:"
puts conf

puts "Opening file #{dst}"

new = File.read(dst)
new.gsub!(/(    # BEGIN EVIL HACK COMMENT DON'T REMOVE.*?# END EVIL HACK COMMENT DON'T REMOVE\s*end)/m, "")

new = "#{new}\n#{conf}\nend"

f = File.open(dst, "w")
f.write(new)
f.close()

puts "Done. OMG, evil!"
