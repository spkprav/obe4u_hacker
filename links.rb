require 'rubygems'
require 'bundler'
Bundler.require

class Link
  def initialize(base_links)
    @base_links = base_links
    @topic_links = nil
    @agent = Mechanize.new do |agent|
              agent.user_agent_alias = (Mechanize::AGENT_ALIASES.keys - ['Mechanize']).sample
              agent.robots = false
            end
  end

  def get
    @base_links.each do |blink|
      blinkh = @agent.get("http://forum.obe4u.com/feed.php?f=#{blink}")
      doc = Nokogiri::HTML.parse(blinkh.body)
      rlinks = []
      doc.children[2].children[0].children[0].children.map { |a| a if a.name == 'entry' }.compact.each do |entry|
        hlink = entry.children.map { |a| a if a.name == 'link' }.compact[0].attributes['href'].value
        rlinks << "http://forum.obe4u.com/posting.php?mode=reply&f=#{blink}&t=#{hlink.split('t=')[1].split('&p')[0]}"
      end
      @topic_links << rlinks
      puts 'praveenfinaltime'
    end
  end
end

links = [10, 1, 2, 3, 4, 8, 11, 9, 7, 6, 5]
link = Link.new(links)
link.get
