# Grucrawler

```ruby
require 'grucrawler'
require 'colorize'

class ItalianCrawler
  def options
    {
        visit_urls_only_once: true,
        follow_redirects: true,
        concurrency: 5,
        domain_wait: 20, # seconds between visits to the same domain
        max_page_size: 1000000
    }
  end

  def on_init(crawler)
    @crawler = crawler
  end

  def on_page_received(typhoeus_response, nokogiri_html)
    puts "GOT #{typhoeus_response.effective_url.green}"

    # typhoeus_response.body
    # typhoeus_response.request.url
    # typhoeus_response.effective_url
    # nokogiri_html.css('a').each |a| { puts a.text; }
  end

  def follow_link(target_url, typhoeus_response, nokogiri_html)
    return false if target_url.match(/\.(jpg|png|js|css|pdf|exe|dmg|zip|doc|rtf|rar|swf|bmp|swf|mp3|wav|mp4|mpg|flv|wma)$/)

    return true if target_url.include? '.it'

    false
  end

  def debug(message)
    #puts message.blue
  end

  def log_info(message)
    puts message.yellow
  end

  def log_error(typhoeus_response, exception)
    puts exception.to_s.red
  end
end

c = GruCrawler.new(ItalianCrawler.new)
# c.reset() # deletes all memory of all events - useful for restarting crawl
c.add_url('http://www.oneworlditaliano.com/english/italian/news-in-italian.htm')
c.run()
```



## Installation

[!] Requires local Redis at the moment.

Add this line to your application's Gemfile:

    gem 'grucrawler'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grucrawler


## Contributing

1. Fork it ( https://github.com/[my-github-username]/grucrawler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
