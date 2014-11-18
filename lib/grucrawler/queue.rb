class GruCrawler
  class DoNotCrawlFurther < Exception
  end

  class Queue
    VISITED_ALREADY_KEY = 'visited_already'
    DOMAIN_VISITS_KEY = 'domain_visits'
    QUEUE_KEY = 'queue'

    def initialize(namespace, visit_once)
      @redis = Redis.new
      @rns = namespace + ':'
      @concurrent_requests = 0
      @tmp_block = {}
      @domains_throttle = Hash.new(0.0)
      @visit_once = visit_once
    end

    def reset
      @redis.del(@rns + DOMAIN_VISITS_KEY)
      @redis.del(@rns + QUEUE_KEY)
      @redis.del(@rns + VISITED_ALREADY_KEY)
    end

    def next_url
      url = ''

      100.times do
        url = random_url_from_queue()

        if visited_already(url) or not can_visit_now(url)
          url = nil
          next
        end

        break
      end

      @tmp_block[url] = true

      url
    end

    MIN_TIME_TO_WAIT = 20

    def can_visit_now(url)
      return false if @tmp_block[url]

      last_visit = last_visit_to_domain(url)
      time_passed = Time.now.to_f - last_visit

      time_passed > MIN_TIME_TO_WAIT
    end

    def started(url)
      set_last_visit_to_domain(url)

      @concurrent_requests += 1
    end

    def finished(url)
      @tmp_block.delete(url)
      set_visited_already(url)
      remove_url_from_queue(url) if url
      @concurrent_requests -= 1
    end

    def count
      @concurrent_requests
    end

    def set_last_visit_to_domain(url)
      time = Time.now.to_f
      @redis.hset(@rns + DOMAIN_VISITS_KEY, domain(url), time)
    end

    def last_visit_to_domain(url)
      @redis.hget(@rns + DOMAIN_VISITS_KEY, domain(url)).to_f
    end


    def remove_url_from_queue(url)
      @redis.srem(@rns + QUEUE_KEY, url)
    end

    def random_url_from_queue
      @redis.srandmember(@rns + QUEUE_KEY)
    end

    def push(url)
      @redis.sadd(@rns + QUEUE_KEY, url) == 1
    end


    def visited_already(url)
      return false unless @visit_once
      @redis.sismember(@rns + VISITED_ALREADY_KEY, url)
    end

    def set_visited_already(url)
      return unless @visit_once
      @redis.sadd(@rns + VISITED_ALREADY_KEY, url)
    end


    # TODO: PublicSuffix
    def domain(url)
      begin
        uri = URI.parse(url)
      rescue URI::InvalidURIError
        return nil
      end

      return nil if uri.host.nil?
      host = uri.host.downcase
      host = host.start_with?('www.') ? host[4..-1] : host
      host.match(/\w+\.\w+$/)[0]
    end
  end
end