namespace :spiderman do
  desc "Run crawlers"
  task :run, [:crawler] => :environment do |task, args|
    Spiderman.run(args[:crawler])
  end

  desc "List available crawlers"
  task list: :environment do
    puts Spiderman.list
  end

  desc ""
  task :debug, [:crawler, :url, :type] => :environment do |task, args|
    unless crawler = Spiderman.find(args[:crawler])
      raise "Can't find crawler with name `#{args[:crawler]}`. " \
        "To list all available crawlers, run: `$ rake crawler:list`"
    end

    crawler.parse!(args[:url], args[:type])
  end

end

task spiderman: 'spiderman:run'
