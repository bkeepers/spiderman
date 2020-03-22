module Spiderman
  class Railtie < Rails::Railtie
    initializer "spiderman" do
      Spiderman::Runner.logger = Rails.logger
    end

    rake_tasks do
      load "spiderman/tasks.rake"
    end
  end
end
