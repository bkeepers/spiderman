module HTTP
  module MimeType
    # This allows you to call `response.parse` and get back a Nokogiri object
    # if the content type is HTML.
    class HTML < Adapter
      def encode(obj)
        obj.to_s if obj
      end

      def decode(str)
        Nokogiri::HTML(str)
      end
    end

    register_adapter "text/html", HTML
    register_alias   "text/html", :html
  end
end
