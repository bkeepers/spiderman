namespace :spiderman do
  # Load the environment and eager load all classes
  task :environment => :environment do
    if defined?(Rails)
      ActiveSupport.run_load_hooks(:before_eager_load, Rails.configuration)
      Rails.configuration.eager_load_namespaces.each(&:eager_load!)
    end

    if defined?(Zeitwerk)
      Zeitwerk::Loader.eager_load_all
    end
  end

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
