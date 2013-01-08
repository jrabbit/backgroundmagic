require "rubygems"
require "bundler/setup"

require 'plist'
require 'nokogiri'

require 'rss'
require 'open-uri'

def get_size
    #Mac Only for now...
    #TODO: Cache this information
    sysinfo = `system_profiler -xml SPDisplaysDataType`
    displays = Plist::parse_xml(sysinfo)[0]['_items'][0]['spdisplays_ndrvs']
    if displays.length > 1
        raise "Not dealing with multiple displays. Cowardly quitting..."
    end
    displays[0]["spdisplays_resolution"].split('x').map {|x| x.strip.to_i}
    #little tricks from FP-land
end

def undopretty resolution
    resolution.split("\u{00D7}") #Really annoying unicode x
end

def foxisblack
    #FoxIsBlack Wallpaper specific code
    url = "http://thefoxisblack.com/category/the-desktop-wallpaper-project/feed/"
    feed = RSS::Parser.parse(open(url))
    feed.items.each do |item|
        h = Nokogiri::HTML(item.content_encoded)
        Hash[h.css('li a').map {|x| [undopretty(x.text), x]} ]
    end
end



puts get_size