module HTTP
  # Module to mix into `HTTP::Response` to make it act like a Nokogiri doc
  module ActAsNokogiriDocument
    def document
      return @document if defined?(@document)
      @document = parse(content_type.mime_type)
    end

    def method_missing(method, *args, &block)
      document.send(method, *args, &block)
    end
  end
end
