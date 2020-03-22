module Spiderman
  class Runner
    class_attribute :logger, instance_accessor: true, default: Logger.new(STDOUT, level: :info)
    attr_reader :urls, :headers

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
  end
end
