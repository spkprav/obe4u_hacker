require 'rubygems'
require 'bundler'
Bundler.require

class Link
  def initialize
    @topic_links = []
    @agent = Mechanize.new do |agent|
              agent.user_agent_alias = (Mechanize::AGENT_ALIASES.keys - ['Mechanize']).sample
            end
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

  # username: praveenfinaltime
  def login
    puts "#{@topic_links.size} topics found"
    puts "Trying to login"
    login_link = "http://forum.obe4u.com/ucp.php?mode=login"
    login_page = @agent.get(login_link)
    logged = @agent.post('./ucp.php?mode=login', { 'username' => 'praveenfinaltime', 'password' => '123456789', 'redirect' => 'index.php', 'sid' => login_page.forms[1].sid, 'login' => 'Login' })
    if logged.body.include?('Logout [ praveenfinaltime ]')
      puts 'Logged in successfully'
      return true
    else
      return false
    end
  end

  def post_everywhere
    puts 'Spreading the truth'
    @topic_links.each do |tlink|
      reply_page = @agent.get(tlink)
      params = {
        'subject' => 'Re: SHARE YOUR FIRST OBE/LD EXPERIENCE'
        'message' => ''
        'creation_time' => '1495015471'
        'form_token' => '497e036151e00b2084624bbcf6ee9bf603cc5931'
        'topic_cur_post_id' => '22678'
        'lastclick' => '1495015471'
        'topic_id' => '5'
        'forum_id' => '10'
        'attach_sig' => '1'
        'post' => 'Submit'
      }
      reply_post = @agent.post(tlink, params)
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
