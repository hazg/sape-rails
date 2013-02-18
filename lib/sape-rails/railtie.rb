module Sape
  class Railtie < ::Rails::Railtie #:nodoc:
  
    initializer 'sape' do |_app|
      Sape::Railtie.load_config
      ActionView::Base.send :include, Sape::Helpers
    end

    def load_config
      #binding.pry
      @config = YAML.load_file(Rails.root.join('config/sape.yml'))
    end

    def config( val )
      @config[val.to_s]
    end

  end
end
