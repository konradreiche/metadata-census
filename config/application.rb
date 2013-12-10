require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module MetadataCensus
  class Application < Rails::Application

    # Unload, then load all metric classes. Required to implement the
    # metaprogramming used to generate application parts based on the
    # available metric classes.
    config.to_prepare do
      metric_files = Dir['app/models/metrics/*.rb']

      metric_files.map do |file_name|
        metric_class = File.basename(file_name, '.rb').camelcase
        loaded = Metrics.constants.include?(metric_class.to_sym)
        Metrics.send(:remove_const, metric_class) if loaded
      end

      Dir['app/models/metrics/*.rb'].each do |file_name|
        load file_name
      end
    end

    Mongoid.logger.level = Logger::INFO
    Moped.logger.level = Logger::INFO

    # Add the svg directory to the asset pipeline
    config.assets.paths << Rails.root.join('app/assets/svg')

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    #
    # Custom directories with classes and modules you want to be autoloadable
    # just once. Reloading can lead to dependency conflicts in the module tree.
    config.autoload_once_paths += Dir["#{config.root}/lib/**/"]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
