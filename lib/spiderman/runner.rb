module Spiderman
  class Runner
    class_attribute :logger, instance_accessor: true, default: Logger.new(STDOUT, level: :info)
    attr_reader :urls, :headers, :handlers

    def initialize
      @urls = []
      @handlers = {}
      @headers = {}
    end

    def start_at(*urls)
      @urls.append(*urls)
    end

    def register(name, &handler)
      @handlers[name] = handler
    end

    def handler_for(name)
      @handlers[name]
    end

    def http
      HTTP.use(logging: {logger: logger}).headers(headers).follow
    end

    def request(url)
      http.get(url).tap do |response|
        response.extend HTTP::ActAsNokogiriDocument
      end
    end

    def dup
      self.class.new.tap do |obj|
        obj.urls.replace(urls)
        obj.handlers.update(handlers)
        obj.headers.update(headers)
        obj.logger = logger
      end
    end

  protected
    # Allow access for dup
    attr_reader :handlers
  end
end
