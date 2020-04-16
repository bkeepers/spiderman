RSpec.describe Spiderman do
  subject { Class.new { include Spiderman } }

  before do
    Spiderman::Runner.logger = Logger.new(STDOUT, level: :unknown)
  end

  it "has a version number" do
    expect(Spiderman::VERSION).not_to be nil
  end

  it "adds a crawler configuration to the class" do
    expect(subject.crawler).to be_instance_of(Spiderman::Runner)
  end

  it "registers urls" do
    subject.crawl "https://example.com", &lambda {}
    expect(subject.crawler.urls).to eq(["https://example.com"])
  end

  describe "name" do
    it "returns underscored name" do
      class MyCrawler; include Spiderman; end
      expect(MyCrawler.new.name).to eq('MyCrawler')
    end

    it "demoduleizes" do
      module MyModule; class MyCrawler; include Spiderman; end; end
      expect(MyModule::MyCrawler.new.name).to eq('MyCrawler')
    end
  end

  describe "crawl!" do
    let!(:request) { stub_request(:get, "https://example.com") }

    it "makes the request" do
      spider.new.crawl!
      expect(request).to have_been_made.once
    end

    it "yields a HTTP::Response to the processor" do
      expect {|b| spider(&b).new.crawl! }.to yield_with_args(HTTP::Response)
    end

    it "requests with configured headers do" do
      spider.crawler.headers[:user_agent] = 'CustomHeader'
      spider.new.crawl!
      expect(request.with(:headers => {user_agent: 'CustomHeader'})).to have_been_requested
    end
  end

  describe "process!" do
    let!(:request) { stub_request(:get, "https://example.com").to_return(body: "Hello World") }

    it "it yields data to the processor" do
      called = false
      data = {a: 1}

      example = self
      spider.process :thing do |response, args|
        example.expect(args).to example.eq(data)
        called = true
      end
      spider.process! "https://example.com", :thing, data

      expect(called).to be(true)
    end
  end

  describe "inheritance" do
    class ApplicationSpider
      include Spiderman
      crawler.headers[:user_agent] = 'The Amazing Spiderman'

      crawl "https://spiders.com" do |res|
      end
    end

    class Spider1 < ApplicationSpider
      crawl "https://cats.com" do |res|
      end
    end
    class Spider2 < ApplicationSpider
      crawl "https://dogs.com" do |res|
      end
    end

    it "dups runner" do
      expect(ApplicationSpider.crawler.urls).to eq(["https://spiders.com"])
      expect(Spider1.crawler.urls).to eq(["https://spiders.com", "https://cats.com"])
      expect(Spider2.crawler.urls).to eq(["https://spiders.com", "https://dogs.com"])
    end

    it "inherits config" do
      expect(Spider1.crawler.headers[:user_agent]).to eq('The Amazing Spiderman')
    end
  end

  describe "module methods" do
    class SpiderMan
      include Spiderman
    end

    describe "list" do
      it "includes crawlers that include the module" do
        expect(Spiderman.list).to include(SpiderMan)
      end

      it "includes subclasses" do
        class PeterParker < SpiderMan
        end
        expect(Spiderman.list).to include(PeterParker)
      end
    end

    describe "find" do
      it "includes finds crawler by name" do
        expect(Spiderman.find('spider_man')).to eq(SpiderMan)
      end
    end
  end

  def spider(&block)
    @spider ||= begin
      block ||= -> (request) { }
      subject.crawl "https://example.com", &block
      subject
    end
  end
end
