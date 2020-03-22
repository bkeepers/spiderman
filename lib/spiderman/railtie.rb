module Spiderman
  class Railtie < Rails::Railtie
    initializer "spiderman" do
      Spiderman.logger = Rails.logger
    end
  end
end
