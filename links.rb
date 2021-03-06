require 'rubygems'
require 'bundler'
Bundler.require

class Link
  def initialize
    @topic_links = []
    @agent = Mechanize.new do |agent|
              agent.user_agent_alias = (Mechanize::AGENT_ALIASES.keys - ['Mechanize']).sample
            end
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.open_timeout = 360
    client.read_timeout = 360
    @browser = Watir::Browser.new :chrome, http_client: client, driver_opts: { args: ['--disable-javascript'] }
  end

  def get
    [10, 1, 2, 3, 4, 8, 11, 9, 7, 6, 5].each do |blink|
      puts "Fetching feed from http://forum.obe4u.com/feed.php?f=#{blink}"
      blinkh = @agent.get("http://forum.obe4u.com/feed.php?f=#{blink}")
      doc = Nokogiri::HTML.parse(blinkh.body)
      rlinks = []
      doc.children[2].children[0].children[0].children.map { |a| a if a.name == 'entry' }.compact.each do |entry|
        hlink = entry.children.map { |a| a if a.name == 'link' }.compact[0].attributes['href'].value
        rlinks << "http://forum.obe4u.com/posting.php?mode=reply&f=#{blink}&t=#{hlink.split('t=')[1].split('&p')[0]}"
      end
      @topic_links << rlinks
    end
    @topic_links.flatten!
  end

  def login
    puts "#{@topic_links.size} topics found"
    puts "Trying to login"
    login_link = "http://forum.obe4u.com/ucp.php?mode=login"
    puts 'browsing the site, please wait...'
    @browser.goto login_link
    username =  @browser.inputs.find { |a| a.id == 'username' }
    password =  @browser.inputs.find { |a| a.id == 'password' }
    username.send_keys "spreadingtruth"
    password.send_keys "123456789"

    submit =  @browser.inputs.find { |a| a.name == 'login' }
    submit.click

    if @browser.url.include?('sid')
      puts 'Logged in'
      return true
    else
      return false
    end
  end

  def post_everywhere
    @topic_links.each do |plink|
      puts "starting: #{plink}"
      @browser.goto plink
      subject = @browser.inputs.find { |a| a.id == 'subject' }
      message = @browser.textareas.find { |a| a.id == 'message' }

      subject.to_subtype.clear
      subject.send_keys "Spreading the truth"
      message.send_keys "I am here to spread the truth"

      submit = @browser.inputs.find{ |a| a.name == 'post' }
      submit.click
      puts "complete: #{plink}"
      byebug
      puts 'done'
    end
  end
end

link = Link.new
link.get
if link.login
  link.post_everywhere
else
  puts 'Not able to login, blocked maybe?'
end
