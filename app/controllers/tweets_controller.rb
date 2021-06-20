class TweetsController < ApplicationController
  
  def index
    response = HTTParty.get('http://twitter.com/newrelic')
    
    icon = Icon.find_by_sql("select pg_sleep(5)")

    parsed_data = Nokogiri::HTML.parse response.body
    tweetNodes = parsed_data.css(".js-tweet-text")
    @nodes = tweetNodes.collect do |node|
      node.inner_html
    end
  end
end
