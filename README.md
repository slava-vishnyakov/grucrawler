# Grucrawler

    require 'grucrawler'

    class ItalianCrawler
      def options
        {
            visit_urls_only_once: true,
            follow_redirects: true
        }
      end

      def on_init(crawler)
        @crawler = crawler
      end

      def on_page_received(typhoeus_response, nokogiri_html)
        puts "GOT #{typhoeus_response.effective_url.green}"
      end

      def follow_link(target_url, typhoeus_response, nokogiri_html)
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
    c.reset()
    c.add_url('http://www.oneworlditaliano.com/english/italian/news-in-italian.htm')
    c.run()



## Installation

Add this line to your application's Gemfile:

    gem 'grucrawler'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grucrawler

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/grucrawler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
