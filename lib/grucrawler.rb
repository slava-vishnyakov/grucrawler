require "grucrawler/version"
require "grucrawler/queue"
require "typhoeus"
require "redis"
require "uri"
require "nokogiri"

class GruCrawler
  class DoNotCrawlFurther < Exception
  end

  def initialize(rules)
    @crawler = rules
    @options = @crawler.options()
    domain_wait = @options[:domain_wait] || 20
    @queue = GruCrawler::Queue.new(@crawler.class.name, @options[:visit_urls_only_once], domain_wait)

    @crawler.on_init(self)
  end

  def run
    @hydra = Typhoeus::Hydra.new()
    @concurrency = @options[:concurrency] || 5
    crawl_more()
    @hydra.run
  end

  def add_url(url)
    @queue.push(url)
  end

  def add_from_queue
    url = @queue.next_url()
    return false unless url

    request = Typhoeus::Request.new(url, followlocation: @options[:follow_redirects], accept_encoding: 'gzip')
    @queue.started(url)

    request.on_complete do |response|
      on_response(response)
    end

    @crawler.debug("#{Time.now} started URL #{url}")
    @hydra.queue(request)

    true
  end

  def reset
    @queue.reset
  end

  def on_response(response)
    @crawler.debug("#{Time.now} ended URL #{response.request.url}")
    @queue.finished(response.request.url)

    crawl_more()

    if response.body.length > (@options[:max_page_size] || 1000*1000*1000)
      @crawler.debug("URL response size too big: #{response.body.length} from #{response.request.url}")
      return
    end

    nokogiri = Nokogiri::HTML(response.body)

    begin
      @crawler.on_page_received(response, nokogiri)
    rescue
      @crawler.log_error(response, $!)
    end

    queue_links(response, nokogiri)

    crawl_more()
  end

  def crawl_more
    while @queue.count < @concurrency
      break unless add_from_queue()
    end
  end

  def queue_links(response, nokogiri)
    nokogiri.css('a').each do |link|
      next unless link['href']

      begin
        url = URI.join(response.effective_url, link['href']).to_s
      rescue
        next
      end
      if @crawler.follow_link(url, response, nokogiri)
        added = add_url(url)
        @crawler.debug("#{Time.now} queued #{url}") if added
      end
    end
  end


end
