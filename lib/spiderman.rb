require "logger"
require "http"
require "http/mime_type/html"
require "http/acts_as_nokogiri_document"
require "active_support/core_ext/class"
require "active_support/core_ext/module"
require "active_support/concern"
require "spiderman/version"
require "spiderman/runner"
require 'spiderman/railtie' if defined?(Rails)

# Turn any class into a crawler by including this module.
#
# Example:
#
#   class MySpider < ApplicationJob # Yup, you can define this in a job
#     queue_as :crawler
#
#     include Spiderman
#
#     crawl "https://example.com/" do |response|
#       response.css('.selector a').each do |a|
#         process! a["href"], :listing
#       end
#     end
#
#     process :listing do |response|
#       process! response.css('img'), :image
#       save_the_thing response.css('.some_selector')
#     end
#
#     process :image do |response|
#       # Do something with the image file
#     end
#
#     def save_the_thing(thing)
#       # logic here for saving the thing
#     end
#  end
#
module Spiderman
  extend ActiveSupport::Concern

  included do
    Spiderman.add(self)
    class_attribute :crawler, instance_reader: true, default: Runner.new

    delegate :logger, to: :crawler
  end

  class_methods do
    delegate :crawl!, :process!, to: :new

    # Use `crawl` to specify URLs to start with. `crawl` accepts one or more
    # URLs, and will call the block for each URL requested. You can also
    # define multiple `crawl` blocks with different behavior for each
    # starting URL. All `crawl` blocks will be called when calling
    # `SpiderName.crawl!`.
    #
    # `response` is an enhanced `HTTP::Response` object that also acts like a
    # `Nokogiri::HTML` document, e.g. `response.css(…)`
    def crawl(*urls, &block)
      urls.each { |url| crawler.register(url, &block) }
      crawler.start_at(*urls)
    end

    # Processors are called from `crawl` and can be used to handle different
    # types of responsezs.
    def process(type, &block)
      crawler.register(type, &block)
    end

    def inherited(subclass)
      subclass.crawler = crawler.dup
      Spiderman.add(subclass)
    end
  end

  def crawl!
    crawler.urls.each do |url|
      process! url
    end
  end

  def process!(url, with = nil)
    if defined?(ActiveJob) && self.is_a?(ActiveJob::Base)
      self.class.perform_later(url.to_s, with)
    else
      perform(url, with)
    end
  end

  def perform(url, with = nil)
    handler = crawler.handler_for(with || url)
    response = crawler.request(url)
    instance_exec response, &handler
  end

  def name
    self.class.name.demodulize
  end

  module_function

  def list
    @list ||= []
  end

  def run(crawler = nil)
    crawlers = crawler ? [find(crawler)] : list
    crawlers.each(&:crawl!)
  end

  def find(name)
    self.list.detect { |crawler| crawler.name.demodulize.underscore == name }
  end

  def add(clazz)
    list.push(clazz)
  end
end
