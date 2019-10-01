require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Peatio
  class Application < Rails::Application

    # Configure Sentry as early as possible.
    if ENV['SENTRY_DSN_BACKEND'].present? && ENV['SENTRY_ENV'].to_s.split(',').include?(Rails.env)
      require 'sentry-raven'
      Raven.configure { |config| config.dsn = ENV['SENTRY_DSN_BACKEND'] }
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    # config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.enforce_available_locales = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[root.join('config', 'locales', '*.{yml}')]
    config.i18n.available_locales = %w(en zh ko)


    config.autoload_paths += [root.join('lib'), root.join('lib/extras'), root.join('lib/cryptocompare')]

    # Observer configuration
    config.active_record.observers = :transfer_observer

    # Don't suppress exceptions in before_commit & after_commit callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.assets.initialize_on_precompile = true

    # Automatically load and reload constants from "lib/peatio".
    config.paths.add 'lib/peatio', eager_load: true, glob: '*'
    config.PASSWORD_FORMAT = /^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[\W]).{8,64}$/
  end
end
