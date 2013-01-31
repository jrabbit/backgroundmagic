#require 'pry'

require "rubygems"
require "bundler/setup"

if !defined?(MACRUBY_VERSION) then
    require 'plist'
else
    framework 'Appkit'
end

require 'nokogiri'

require 'rss'
require 'open-uri'

class Resolution
    attr_accessor :x, :y 
    def initialize(x, y)
        @x = x
        @y = y
    end
    
    def self.string(s)
        if s.include?('x')
            x, y = s.split('x')
        else
            x, y = s.split("\u{00D7}")
        end
        new(Integer(x),Integer(y))
    end
    
    def to_s
        "#{@x} x #{@y}"
    end
end

#Macruby!
def Mac_get_size
    screen = NSScreen.mainScreen.frame
    Resolution(screen.size.width, screen.size.height)
end

def get_size_hack
    #Mac Only for now...
    #Depricated.
    #TODO: Cache this information
    sysinfo = `system_profiler -xml SPDisplaysDataType`
    displays = Plist::parse_xml(sysinfo)[0]['_items'][0]['spdisplays_ndrvs']
    if displays.length > 1
        raise "Not dealing with multiple displays. Cowardly quitting..."
    end
    Resolution.string(displays[0]["spdisplays_resolution"])
end

def get_size
    if !defined?(MACRUBY_VERSION) then
        get_size_hack
    else
        Mac_get_size
end
    
def foxisblack
    #FoxIsBlack Wallpaper specific code
    url = "http://thefoxisblack.com/category/the-desktop-wallpaper-project/feed/"
    feed = RSS::Parser.parse(open(url))
    feed.items.each do |item|
        h = Nokogiri::HTML(item.content_encoded)
        #no ipads, iphones or iphone5s.
        Hash[h.css('li a').select {|x| ! x.text.include?('i')}
            .map {|x| [Resolution.string(x.text), x]}]
    end
end



puts get_size, foxisblack